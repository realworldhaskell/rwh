import Prelude hiding (filter, foldl, foldr)

{-- snippet foldl --}
foldl :: (a -> b -> a) -> a -> [b] -> a

foldl f z xs = helper z xs
    where helper z []     = z
          helper z (x:xs) = helper (f z x) xs
{-- /snippet foldl --}

{-- snippet foldr --}
foldr :: (a -> b -> b) -> b -> [a] -> b

foldr f z xs = helper xs
     where helper []     = z
           helper (y:ys) = f y (helper ys)
{-- /snippet foldr --}

{-- snippet myMap --}
myMap :: (a -> b) -> [a] -> [b]

myMap f xs = foldr step [] xs
    where step x [] = [f x]
          step x ys = f x : ys
{-- /snippet myMap --}

{-- snippet myFoldl --}
myFoldl :: (a -> b -> a) -> a -> [b] -> a

myFoldl f z xs = foldr step id xs z
    where step x g a = g (f a x)
{-- /snippet myFoldl --}

{-- snippet filter --}
filter :: (a -> Bool) -> [a] -> [a]
filter p []   = []
filter p (x:xs)
    | p x       = x : filter p xs
    | otherwise = filter p xs
{-- /snippet filter --}

{-- snippet myFilter --}
myFilter p xs = foldr step [] xs
    where step x ys | p x       = x : ys
                    | otherwise = ys
{-- /snippet myFilter --}
