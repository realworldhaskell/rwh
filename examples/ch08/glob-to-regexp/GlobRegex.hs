module GlobRegex
    (
      globToRegex
    , matchesGlob
    ) where

import Text.Regex.Posix ((=~))

{-- snippet type --}
globToRegex :: String -> String
{-- /snippet type --}

{-- snippet rooted --}
globToRegex cs = '^' : globToRegex' cs
{-- /snippet rooted --}

{-- snippet asterisk --}
globToRegex' :: String -> String
globToRegex' "" = "$"
globToRegex' ('*':cs) = ".*" ++ globToRegex' cs
{-- /snippet asterisk --}

{-- snippet question --}
globToRegex' ('?':cs) = '.' : globToRegex' cs
{-- /snippet question --}

{-- snippet class --}
globToRegex' ('[':'!':c:cs) = "[^" ++ c : charClass cs
globToRegex' ('[':c:cs) = '[' : c : charClass cs
globToRegex' ('[':_) = error "unterminated character class"
{-- /snippet class --}
{-- snippet last --}
globToRegex' (c:cs) = escape c ++ globToRegex' cs
{-- /snippet last --}

{-- snippet escape --}
escape :: Char -> String
escape c
    | c `elem` regexChars = '\\' : [c]
    | otherwise = [c]
    where regexChars = "\\+()^$.{}]|"
{-- /snippet escape --}

{-- snippet charClass --}
charClass :: String -> String
charClass (']':cs) = ']' : globToRegex' cs
charClass (c:cs) = c: charClass cs
charClass [] = error "unterminated character class"
{-- /snippet charClass --}

{-- snippet matchesGlob --}
matchesGlob :: FilePath -> String -> Bool
name `matchesGlob` pat = name =~ globToRegex pat
{-- /snippet matchesGlob --}
