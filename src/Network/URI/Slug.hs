{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE InstanceSigs #-}

module Network.URI.Slug
  ( Slug (unSlug),
    decodeSlug,
    encodeSlug,
  )
where

import Data.Aeson (FromJSON, ToJSON)
import Data.Data (Data)
import Data.Text qualified as T
import Data.Text.Normalize qualified as UT
import Network.URI.Encode qualified as UE

-- | An URL path is made of multiple slugs, separated by '/'
newtype Slug = Slug {unSlug :: Text}
  deriving stock (Eq, Show, Ord, Data, Generic)
  deriving anyclass (ToJSON, FromJSON)

-- | Decode an URL component into a `Slug` using `Network.URI.Encode`, as well
-- as unicode normalize it.
decodeSlug :: Text -> Slug
decodeSlug =
  fromString . UE.decode . toString

-- | Encode a `Slug` into an URL component using `Network.URI.Encode`
encodeSlug :: Slug -> Text
encodeSlug =
  UE.encodeText . unSlug

instance IsString Slug where
  fromString :: HasCallStack => String -> Slug
  fromString (toText -> s) =
    if "/" `T.isInfixOf` s
      then error ("Slug cannot contain a slash: " <> s)
      else Slug (unicodeNormalize s)

-- Normalize varying non-ascii strings (in filepaths / slugs) to one
-- representation, so that they can be reliably linked to.
unicodeNormalize :: Text -> Text
unicodeNormalize = UT.normalize UT.NFC . toText
