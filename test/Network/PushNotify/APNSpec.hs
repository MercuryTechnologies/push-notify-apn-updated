{-# LANGUAGE OverloadedStrings #-}

module Network.PushNotify.APNSpec (spec) where

import           Data.Aeson
import           Network.PushNotify.APN
import           Test.Hspec

spec :: Spec
spec = do
  describe "JsonApsMessage" $
    context "JSON encoder" $ do
      it "encodes an APNS message with a title and body" $
        toJSON (alertMessage "hello" "world" Nothing) `shouldBe`
          object [
            "category" .= Null,
            "sound"    .= Null,
            "badge"    .= Null,
            "mutable-content" .= Null,
            "interruption-level" .= Null,
            "alert"    .= object [
              "title" .= String "hello",
              "body"  .= String "world"
            ]
          ]
      it "encodes an APNS message with a title, subtitle and body" $
        toJSON (alertMessage "hello" "world" (Just "there")) `shouldBe`
          object [
            "category" .= Null,
            "sound"    .= Null,
            "badge"    .= Null,
            "mutable-content" .= Null,
            "interruption-level" .= Null,
            "alert"    .= object [
              "title" .= String "hello",
              "subtitle" .= String "there",
              "body"  .= String "world"
            ]
          ]
      it "encodes an APNS message with a title and no body" $
        toJSON (bodyMessage "hello world") `shouldBe`
          object [
            "category" .= Null,
            "sound"    .= Null,
            "badge"    .= Null,
            "mutable-content" .= Null,
            "interruption-level" .= Null,
            "alert"    .= object [ "body"  .= String "hello world" ]
          ]

  describe "JsonAps" $
    context "JSON encoder" $ do
      it "encodes normally when there are no supplemental fields" $
        toJSON (newMessage (alertMessage "hello" "world" Nothing)) `shouldBe` object [
          "aps"                .= alertMessage "hello" "world" Nothing,
          "appspecificcontent" .= Null,
          "data" .= object []
        ]

      it "encodes supplemental fields" $ do
        let msg = newMessage (alertMessage "hello" "world" Nothing)
                  & addSupplementalField "foo" ("bar" :: String)
                  & addSupplementalField "aaa" ("qux" :: String)

        toJSON msg `shouldBe` object [
            "aps"                .= alertMessage "hello" "world" Nothing,
            "appspecificcontent" .= Null,
            "data"               .= object ["aaa" .= String "qux", "foo" .= String "bar"]
          ]

  describe "ApnFatalError" $
    context "JSON decoder" $ do
      it "decodes the error correctly" $
        eitherDecode "\"BadCollapseId\"" `shouldBe` Right ApnFatalErrorBadCollapseId

      it "dumps unknown error types into a wildcard result" $
        eitherDecode "\"BadcollapseId\"" `shouldBe` Right (ApnFatalErrorOther "BadcollapseId")

  describe "ApnTemporaryError" $
    context "JSON decoder" $
      it "decodes the error correctly" $
        eitherDecode "\"TooManyProviderTokenUpdates\"" `shouldBe` Right ApnTemporaryErrorTooManyProviderTokenUpdates
  where
    (&) = flip ($)
