### Let's analyze the "Oposite of Filter using Fold" problem

```haskell
pairIfEven :: Integer -> [Integer]
pairIfEven i = if even i then [i] else [i-1, i+1]
```

Using concatMap we can get the opposite effect of filter, we actually get a higer cardinality...
```haskell
concatMap pairIfEven [1,2,3,4]
-- [0,2,2,2,4,4]
```
Let's look at the actual implementation of concatMap 

```haskell
concatMap    :: (a -> [b]) -> [a] -> [b]
concatMap f  =  foldr ((++) . f) []
```
basically it uses foldr and the concatenation after the maping function.

note: this concatenation its also called flattening in other contexts

So now the question becomes is there an equivalent of concatMap that 
produces not a list but another type? lets replace the List notation for a Type notation:

```haskell
(a -> T b) -> T a -> T b
```

Lets use Hoogle it. hmm... It turns out there is one...
```haskell
(=<<) :: Monad m => (a -> m b) -> m a -> m b
```

...And it seems that this function is pretty much  >>= with the order of the arguments reversed

```haskell
:i (>>=)
class Applicative m => Monad (m :: * -> *) where
(>>=) :: m a -> (a -> m b) -> m b
```

And... this one is called Bind wich is the minimal implementation needed for a Monad

```haskell
:i Monad
class Applicative m => Monad (m :: * -> *) where
  (>>=) :: m a -> (a -> m b) -> m b
  (>>) :: m a -> m b -> m b
  return :: a -> m a
  fail :: String -> m a
  {-# MINIMAL (>>=) #-}
```

So... the new question is: "Can we use FoldR to explain Monads?" 
