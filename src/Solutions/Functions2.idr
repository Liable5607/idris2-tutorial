module Solutions.Functions2

import Data.List

%default total

--------------------------------------------------------------------------------
--          Let Bindings and Where Blocks
--------------------------------------------------------------------------------

-- 1
record Artist where
  constructor MkArtist
  name : String

record Album where
  constructor MkAlbum
  name   : String
  artist : Artist

record Email where
  constructor MkEmail
  value : String

record Password where
  constructor MkPassword
  value : String

record User where
  constructor MkUser
  name     : String
  email    : Email
  password : Password
  albums   : List Album

Eq Artist where (==) = (==) `on` name

Eq Email where (==) = (==) `on` value

Eq Password where (==) = (==) `on` value

Eq Album where (==) = (==) `on` \a => (a.name, a.artist)

record Credentials where
  constructor MkCredentials
  email    : Email
  password : Password

record Request where
  constructor MkRequest
  credentials : Credentials
  album       : Album

data Response : Type where
  UnknownUser     : Email -> Response
  InvalidPassword : Response
  AccessDenied    : Email -> Album -> Response
  Success         : Album -> Response

DB : Type
DB = List User

handleRequest : DB -> Request -> Response
handleRequest xs (MkRequest (MkCredentials e pw) album) =
  case find ((e ==) . email) xs of
    Nothing => UnknownUser e
    Just (MkUser _ _ pw' albums)  =>
      if      pw' /= pw         then InvalidPassword
      else if elem album albums then Success album
      else                           AccessDenied e album

--2

namespace Ex2

  data Failure : Type where
    UnknownUser : Email -> Failure
    InvalidPassword : Failure
    AccessDenied : Email -> Album -> Failure

  handleRequest : DB -> Request -> Either Failure Album
  handleRequest db req = case find ((==) req.credentials.email . email) db of
    Nothing => Left (UnknownUser req.credentials.email)
    Just u2 => case (u2.email == req.credentials.email && u2.password == req.credentials.password) of
      False => Left InvalidPassword
      True => case elem req.album u2.albums of
        False => Left (AccessDenied req.credentials.email req.album)
        True => Right req.album

-- 3
data Nucleobase = Adenine | Cytosine | Guanine | Thymine

readBase : Char -> Maybe Nucleobase
readBase 'A' = Just Adenine
readBase 'C' = Just Cytosine
readBase 'G' = Just Guanine
readBase 'T' = Just Thymine
readBase c   = Nothing

-- 4
traverseList : (a -> Maybe b) -> List a -> Maybe (List b)
traverseList _ []        = Just []
traverseList f (x :: xs) =
  case f x of
    Just y  => case traverseList f xs of
      Just ys => Just (y :: ys)
      Nothing => Nothing
    Nothing => Nothing

-- 5
DNA : Type
DNA = List Nucleobase

readDNA : String -> Maybe DNA
readDNA = traverseList readBase . unpack

-- 6
complement : DNA -> DNA
complement = map comp
  where comp : Nucleobase -> Nucleobase
        comp Adenine  = Thymine
        comp Cytosine = Guanine
        comp Guanine  = Cytosine
        comp Thymine  = Adenine
