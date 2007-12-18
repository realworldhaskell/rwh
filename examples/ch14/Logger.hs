{-- snippet module --}
module Logger
    (
      Logger
    , Log
    , execLogger
    , record
    ) where
{-- /snippet module --}

{-- snippet Log --}
type Log = [String]
{-- /snippet Log --}

{-- snippet Logger --}
newtype Logger a = Logger { runLogger :: (a, Log) }
{-- /snippet Logger --}

{-- snippet return --}
instance Monad Logger where
    return a = Logger (a, [])
{-- /snippet return --}
{-- snippet bind --}
    m >>= k = let (a, w) = runLogger m
                  n      = k a
                  (b, x) = runLogger n
              in Logger (b, w ++ x)
{-- /snippet bind --}

{-- snippet stricterBind --}
stricterBind :: Logger a -> (a -> Logger a1) -> Logger a1
stricterBind m k =
    case runLogger m of
      (a, w) -> let (b, x) = runLogger (k a)
                in Logger (b, w ++ x)
{-- /snippet stricterBind --}

{-- snippet execLogger.type --}
execLogger :: Logger a -> (a, Log)
{-- /snippet execLogger.type --}
{-- snippet execLogger --}
execLogger = runLogger
{-- /snippet execLogger --}

{-- snippet record.type --}
record :: String -> Logger ()
{-- /snippet record.type --}
{-- snippet record --}
record s = Logger ((), [s])
{-- /snippet record --}

{-- snippet globToRegex.type --}
globToRegex :: String -> Logger String
{-- /snippet globToRegex.type --}

{-- snippet rooted --}
globToRegex cs =
    globToRegex' cs >>= \ds ->
    return ('^':ds)
{-- /snippet rooted --}

{-- snippet eof --}
globToRegex' :: String -> Logger String
globToRegex' "" = return "$"
{-- /snippet eof --}

{-- snippet question --}
globToRegex' ('?':cs) =
    record "any" >>
    globToRegex' cs >>= \ds ->
    return ('.':ds)
{-- /snippet question --}

{-- snippet asterisk --}
globToRegex' ('*':cs) = do
    record "kleene star"
    ds <- globToRegex' cs
    return (".*" ++ ds)
{-- /snippet asterisk --}

{-- snippet class --}
globToRegex' ('[':'!':c:cs) =
    record "character class, negative" >>
    charClass cs >>= \ds ->
    return ("[^" ++ c : ds)
globToRegex' ('[':c:cs) =
    record "character class" >>
    charClass cs >>= \ds ->
    return ("[" ++ c : ds)
globToRegex' ('[':_) =
    fail "unterminated character class"
{-- /snippet class --}
{-- snippet last --}
globToRegex' (c:cs) = liftM2 (++) (escape c) (globToRegex' cs)
{-- /snippet last --}

{-- snippet escape --}
escape :: Char -> Logger String
escape c
    | c `elem` regexChars = record "escape" >> return ('\\' : [c])
    | otherwise = return [c]
    where regexChars = "\\+()^$.{}]|"
{-- /snippet escape --}

{-- snippet charClass_wordy --}
charClass_wordy (']':cs) =
    globToRegex' cs >>= \ds ->
    return (']':ds)
charClass_wordy (c:cs) =
    charClass_wordy cs >>= \ds ->
    return (c:ds)
{-- /snippet charClass_wordy --}

{-- snippet charClass --}
charClass (']':cs) = (']':) `liftM` globToRegex' cs
charClass (c:cs) = (c:) `liftM` charClass cs
{-- /snippet charClass --}

{-- snippet liftM --}
liftM :: (Monad m) => (a -> b) -> m a -> m b
liftM f m = m >>= \i ->
            return (f i)
{-- /snippet liftM --}

{-- snippet liftM2 --}
liftM2 :: (Monad m) => (a -> b -> c) -> m a -> m b -> m c
liftM2 f m1 m2 =
    m1 >>= \a ->
    m2 >>= \b ->
    return (f a b)
{-- /snippet liftM2 --}
