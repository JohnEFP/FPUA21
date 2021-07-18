GOAL
===
The problem we are solving is the one of parsing a list of charachters, this will eventually result in a set of values of the type JsonValue


Types
----

#### JsonValue

JsonValue represents a parsed piece of the input String.

The possible set of constructors, that include null or object can be defined deriving show and eq, note the recursive nature in JsonArray and JsonObject.

```haskell
data TJsonValue
  = CJsonNull
  | CJsonBool Bool
  | CJsonNumber Integer -- NOTE: no support for floats
  | CJsonString String
  | CJsonArray [TJsonValue]
  | CJsonObject [(String, TJsonValue)]
  deriving (Show, Eq)
```

#### CParser
Parser is the type that will help us encapsulate a computation, is a polymorphic type
```haskell
newtype TParser a = CParser { runParser :: String -> Maybe (String, a) }
```
Note that its actually an alias for a type for which its only constructor takes function that goes from String to a Maybe of a pair of String and the polymophic type a.

The principle is that a parser will turn a sequence of characters into a Maybe that may wrap a pair of a substring of the input and the parsed portion as a value of type "a", After the input is consumed the input and empty string will signal the end of the computations.

```haskell
String -> Maybe (String, a)
```
More info on newType can be found at 
[haskell newtype](https://wiki.haskell.org/Newtype)

Parsers
----
#### CharParser
This is the base parser, as it parses only one characther.

Nothe that there is no CJsonChar constructor, as in json there are no one characther "components", this function will help to actually define other parsers like the "nullParser" and the "stringParser" 

```haskell
charP :: Char -> TParser Char
charP x = CParser f
  where
    f (y:ys)
      | y == x = Just (ys, x)
      | otherwise = Nothing
    f [] = Nothing
```

It goes from Char to "Parser Char". and that actualy means that we will eventually  get:

```haskell
runParser :: String -> Maybe (String, Char)
```

##### Interpretation
We shall provide a function implementation that matches the expected signature, to do that we use the "CParser" construtor to which we pass a function that uses patter matching this way:

If the f gets a empty string we return Nothing

In case it is not an empty string:

  1. If the head of the characters list is equal to the elment we need to look for "x" we return a Just of a Pair from the tail and the matched character.
  2. If there are no coincidences we also return Nothing.


Parsers
----
#### Functor 

##### Motivation for Functors
In order to be able to construct a function that pulls values of a exact match like for instance:

```haskell
jsonNull :: TParser TJsonValue
jsonNull = (\_ -> CJsonNull) <$> stringP "null"
```

We will need to create an auxiliary function in the same fasihion we defined charP
```haskell
stringP :: String -> TParser String
```

We could use built in functions for composing charP coputations in order to get an implementation
```haskell
stringP :: String -> TParser String
stringP = sequenceA . map charP
```
or the equivalent

```haskell
stringP :: String -> TParser String
stringP = traverse charP
```
In order to use these built in funcitons we need to first prove that TParser is a Functor
##### Functor Prove

```haskell
instance Functor TParser where
  fmap f (CParser pfn) = CParser $ \input -> do
    (resultLeftToParse, x)  <-  pfn input
    Just (resultLeftToParse, f x)
```

To prove TParser is a Functor, we do that by prsenting a function fmap such as:

```haskell
fmap :: (a -> b) -> TParser a -> TParser b
```

As there is only one way to construct a CParser then we can figure _a (the polymorphic function implementation)
```haskell
fmap f (CParser pfn) = CParser _a
-- hole:
_a :: String -> Maybe (String, b)
```

Using holes we now can prepare a lambda function that can will take input and apply pnf to it producing a pair with the unparsed string and x of type a

```haskell
\input -> do
    (resultLeftToParse, x)  <-  pfn input
```

with that we just need to construct the resulting Monad value, in this case 

```haskell
    Just (resultLeftToParse, f x)
```

For a novice reader the hard part will be to understand how we were able to use the do notation, this has to do with the fact that pnf produces a Monad.

##### Functor Conclusion

We now proved that TParser is a Functor type because no matter the type of "a" if you present a function from "a" to "b" we now can give you a function from "TParser a -> TParser b"

```haskell
fmap :: (a -> b) -> (TParser a -> TParser b)
```
====To Be Continued

Notes
===

1. I took the liberty to prefix constructors with a "C" and Types with a "T", and also to change some identifiers names like f to "pfn"
2. Please add comments or edits to the project.
