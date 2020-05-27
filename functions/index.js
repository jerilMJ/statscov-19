const functions = require("firebase-functions");
const fetch = require("node-fetch");
const { URLSearchParams } = require("url");

exports.sendUserResponseToken = functions.https.onCall(
  async (token, context) => {
    const params = new URLSearchParams();
    const url = "https://recaptcha.google.com/recaptcha/api/siteverify";

    params.append("secret", functions.config().recaptcha.secret);
    params.append("response", token);

    const response = await fetch(url, {
      method: "post",
      body: params,
    });

    const result = await response.json();
    console.log(result);

    return result;
  }
);
