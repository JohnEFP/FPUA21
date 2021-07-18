module Main where

import Data.Char
import Control.Applicative

newtype TParser a = CParser { runParser :: String -> Maybe (String, a) }

charP :: Char -> TParser Char
charP x = CParser f
  where
    f (y:ys)
      | y == x = Just (ys, x)
      | otherwise = Nothing
    f [] = Nothing

instance Functor TParser where
  fmap f (CParser pfn) = CParser $ \input -> do
    (resultLeftToParse, x)  <-  pfn input
    Just (resultLeftToParse, f x)

instance Applicative TParser where
  pure x = CParser $ \input -> Just (input, x)
  (CParser p1) <*> (CParser p2) =
    CParser $ \input -> do
      (input', f) <- p1 input
      (input'', a) <- p2 input'
      Just (input'', f a)

stringP :: String -> TParser String
stringP = sequenceA . map charP

data TJsonValue
  = CJsonNull
  | CJsonBool Bool
  | CJsonNumber Integer -- NOTE: no support for floats
  | CJsonString String
  | CJsonArray [TJsonValue]
  | CJsonObject [(String, TJsonValue)]
  deriving (Show, Eq)

jsonNull :: TParser TJsonValue
jsonNull = (\_ -> CJsonNull) <$> stringP "null"

jsonBool :: TParser TJsonValue
jsonBool = f <$> (stringP "true" <|> stringP "false")
   where f "true"  = CJsonBool True
         f "false" = CJsonBool False
         -- This should never happen
         f _       = undefined

spanP :: (Char -> Bool) -> TParser String
spanP f =
  CParser $ \input ->
    let (token, rest) = span f input
     in Just (rest, token)

notNull :: TParser [a] -> TParser [a]
notNull (CParser p) =
  CParser $ \input -> do
    (input', xs) <- p input
    if null xs
      then Nothing
      else Just (input', xs)

jsonNumber :: TParser TJsonValue
jsonNumber = f <$> notNull (spanP isDigit)
    where f ds = CJsonNumber $ read ds

-- NOTE: no escape support
stringLiteral :: TParser String
stringLiteral = charP '"' *> spanP (/= '"') <* charP '"'

jsonString :: TParser TJsonValue
jsonString = CJsonString <$> stringLiteral

ws :: TParser String
ws = spanP isSpace

sepBy :: TParser a -> TParser b -> TParser [b]
sepBy sep element = (:) <$> element <*> many (sep *> element) <|> pure []

jsonArray :: TParser TJsonValue
jsonArray = CJsonArray <$> (charP '[' *> ws *>
                           elements
                           <* ws <* charP ']')
  where
    elements = sepBy (ws *> charP ',' <* ws) jsonValue

jsonObject :: TParser TJsonValue
jsonObject =
  CJsonObject <$> (charP '{' *> ws *> sepBy (ws *> charP ',' <* ws) pair <* ws <* charP '}')
  where
    pair =
      (\key _ value -> (key, value)) <$> stringLiteral <*>
      (ws *> charP ':' <* ws) <*>
      jsonValue

jsonValue :: TParser TJsonValue
jsonValue = jsonNull <|> jsonBool <|> jsonNumber <|> jsonString <|> jsonArray <|> jsonObject

instance Alternative TParser where
  empty = CParser $ \_ -> Nothing
  (CParser p1) <|> (CParser p2) =
      CParser $ \input -> p1 input <|> p2 input

parseFile :: FilePath -> TParser a -> IO (Maybe a)
parseFile fileName parser = do
  input <- readFile fileName
  return (snd <$> runParser parser input)

main :: IO ()
main = undefined
