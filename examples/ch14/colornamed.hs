{-- snippet custom --}
data CustomColor2 = 
  CustomColor2 {red :: Int,
                green :: Int,
                blue :: Int}
  deriving (Eq, Show, Read)
{-- /snippet custom --}

{-- snippet changered --}
changeRed :: CustomColor2 -> Int -> CustomColor2
changeRed cc newRed = cc {red = newRed}
{-- /snippet changered --}

{-- snippet extract --}
color2string :: CustomColor2 -> String
color2string cc =
    "red: " ++ show (red cc) ++ ", green: " ++ show (green cc) 
    ++ ", blue: " ++ show (blue cc)
{-- /snippet extract --}

{-- snippet extract2 --}
color2string2 :: CustomColor2 -> String
color2string2 (CustomColor2 red green blue) =
    "red: " ++ show red ++ ", green: " ++ show green ++ ", blue: "
    ++ show blue
{-- /snippet extract2 --}
