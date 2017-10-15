module Powers where

type World = [[Int]]

createPair :: (a -> a) -> a -> (a, a)
createPair f a = (a, f a)

replaceElement :: [a] -> Int -> a -> [a]
replaceElement xs i x = prefix ++ (x : postfix) where
    prefix = take i xs
    postfix = drop (i + 1) xs

replaceCell :: (Int, Int) -> Int -> World -> World
replaceCell (i, j) x w = replaceElement w i newLine where
    newLine = replaceElement (w !! i) j x

find :: (World -> a -> Bool) -> World -> [a] -> [a]
find p w = filter (p w)

allCoords = [(0,0), (0,1), (0,2), (0,3),
             (1,0), (1,1), (1,2), (1,3),
             (2,0), (2,1), (2,2), (2,3),
             (3,0), (3,1), (3,2), (3,3)]

movingUpCoords = filter (getMovingTilesFilter Up) allCoords

movingPairs :: Dir -> [((Int, Int), (Int, Int))]
movingPairs dir = filter (\(a, b) -> isValid a && isValid b) $
    map (createPair (getTowardsCoords dir)) allCoords
isValid :: (Int, Int) -> Bool
isValid (i,j) = valid i && valid j where
    valid z = 0 <= z && z <= 3

at :: World -> (Int, Int) -> Int
at w (i, j) = w !! i !! j

isZeroPair :: World -> (Int, Int) -> (Int, Int) -> Bool
isZeroPair w a b = w `at` a /= 0 && w `at` b == 0
isEqualPair :: World -> (Int, Int) -> (Int, Int) -> Bool
isEqualPair w a b = w `at` a == w `at` b

move :: Dir -> World -> World
move dir w = foldl swap w zeroTopPairs where
    zeroTopPairs :: [((Int, Int), (Int, Int))]
    zeroTopPairs = find (uncurry . isZeroPair) w $ movingPairs dir
    swap :: World -> ((Int, Int), (Int, Int)) -> World
    swap w (a,b) = replaceCell a y $ replaceCell b x w where
        x = w `at` a
        y = w `at` b
squash dir w = foldl squash w equalPairs where
    equalPairs = find (uncurry . isEqualPair) w $ movingPairs dir
    squash :: World -> ((Int, Int), (Int, Int)) -> World
    squash w (a,b) = replaceCell a 0 $ replaceCell b sum w where
        sum = w `at` a + w `at` b

data Dir = Up | Down | Left | Right

getMovingTilesFilter :: Dir -> ((Int, Int) -> Bool)
getMovingTilesFilter Up = \(i, _) -> i /= 0
getMovingTilesFilter _ = undefined

-- get the coordinates of tile towards which (i, j) tile will be moving in
-- specified direction
getTowardsCoords :: Dir -> (Int, Int) -> (Int, Int)
getTowardsCoords Up (i, j) = (i-1, j)
getTowardsCoords _ _ = undefined

up :: World -> World
up = (squash Up) . (move Up)

update :: Char -> World -> World
update 'w' = up . up . up . up . up
-- todo for "asd" keys
update _ = id

