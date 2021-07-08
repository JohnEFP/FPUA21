-- Auxiliary function, TODO find the one from prelude that can be used instead
merge :: [a] -> [a] -> [a]
merge [] ys = ys
merge (x:xs) ys = x:merge ys xs

source :: [Integer]
source = [2,3,9999,4,5]

-- Nothing important, just a non-empty list to feed the foldr
start :: String
start = ['A']

-- Example function that maps Integer to Char
letterFromNumber :: Integer -> Char
letterFromNumber 2 = 'B'
letterFromNumber 3 = 'C'
letterFromNumber 4 = 'B'
letterFromNumber _  = 'Z'

-- this does a simple map  using letterFromNumber
translate :: Integer -> String -> String
translate n acc = merge acc [letterFromNumber n]

-- this one is fancier as in addition to map we also filter out the elements > 5
translateAndFilter :: Integer -> String -> String
translateAndFilter n acc = if n > 5 then merge acc [letterFromNumber n] else acc

-- Using foldr we can do a kind of mapping to all the elements of the original list
foldOverTranslate :: String
foldOverTranslate = foldr translate start source
-- >>> foldOverTranslate
-- "ABCZBZ"

-- we could also use the foldr to filter elements on the list
foldOverTranslateAndFilter :: String
foldOverTranslateAndFilter = foldr translateAndFilter start source
-- >>> foldOverTranslateAndFilter
-- "AZ"
