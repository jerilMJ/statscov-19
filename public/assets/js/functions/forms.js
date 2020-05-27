import { App } from "../utils/app.js";

export function setupForms(captchas) {
  setupAndroidDownloadForm();
  setupBugReportForm(captchas);
  setupFeedbackForm(captchas);
}

function setupAndroidDownloadForm() {
  const androidDownloadForm = document.getElementsByClassName(
    "android-download-form"
  )[0];

  androidDownloadForm.addEventListener("submit", (event) => {
    event.preventDefault();
    let url;

    switch (androidDownloadForm["cpu-architecture"].value) {
      case "arm-32-bit":
        url =
          "https://labs-dl-signed.xda-cdn.com/apks/86498472-1095-471c-8cb1-dd35cc7590dd.apk?Signature=AS4gYxliUx-xGmlmMMFmWkh0bezEijt-P-m0kgmLook5tp38EdTbg7F0rU-ZLfmTF-5HP0TT5kfbCk-Fi6zVYk9Xif3qAE8CEcI88jD95pSuztHimUYuw557QJgFB3TMhDhRL22BzFfap2ggYXglQgJHHBivft1Sy0kPkOlCu28b7-Hm8HAtYL-~guJhyRZVDUQgLnzavZX42JDbYt7-3412SFy~~7t-Ptzp7~SKn6Kl-1SEJhPspxNptd7n4Cp~1JoZptzbhHDwoIriiLwXikaqc5bS41N1qFGS57q3AoxyGQRUfkOLAstoLKZ1CiEhpDt6JntFUEnXOJ6Ny2KCpA__&Expires=1590556856&Key-Pair-Id=APKAJRXMMHY3RDXVM6BA";
        break;
      case "arm-64-bit":
        url =
          "https://labs-dl-signed.xda-cdn.com/apks/4062a73b-a60e-4ae3-a351-4b55e7e4bca0.apk?Signature=gZKeD~Ll6hQZSrpWi4T0v9kaxHXygSVKfJ9bMyrhwc~ooW6z0wlpppgCsb4IBr5VMQEcF0q2uOgIEU6AKICRxtMcLMPE3Xpx~PKUAIv5zt111zpiIXOWFbGkEGRE22scatwlB6KbUbSVvHWulFN1jzXy5JdRlgXpfv-uVmpNn9~wjnLRulmcipNxXWsokpU~LlIFiWjSvYZeoAEkZVx8prECU76yL1c-lRmyIxGboifNCixUt4q~ifKbohwVerQr6Md4i8gEgQ3GtRzV9Yh6lDGjKo35pqa9yHuMA6BT3wWKyetTr2kY0ktU2ZhDzhNlnud~EXx~TMcLvy52V5QJmw__&Expires=1590557063&Key-Pair-Id=APKAJRXMMHY3RDXVM6BA";
        break;
      case "x86-64-bit":
        url =
          "https://labs-dl-signed.xda-cdn.com/apks/626ba614-f5f1-4f97-960c-e453be1d83b6.apk?Signature=DtYAGdcZcjolvr-L1420mCoFZXlvblZX60pJuku729pgajkgxnwHlv3zO6j8koQZZHx19yGZZVY058J6VA5O9V1Mhtiq6H2MEvQa0MngqWZc3DBa5SITqPsMX4S~BNKgwLj52iCnUea8hFjPmFpOUASKJwBULW2kyFk79EtYO~zsj-OHuSJ7vNZNBqvyfnKtnkr13fc-y2EBNrEsMjgLPxmGP6ZZuQIecMsXjj96PdzoFKNgoXcIVsvTrceafK6eQI27Nf9v3mBRwlcJxAzAd5y84FodVYuV~XRaJp~I4lghyGZK9k5NH78Lm42H1GD3fDLA6COVQbU8WJBY8B1H2g__&Expires=1590557290&Key-Pair-Id=APKAJRXMMHY3RDXVM6BA";
        break;
      case "idk":
        url =
          "https://labs-dl-signed.xda-cdn.com/apks/17d2f777-7a39-4024-ad80-a0e5a8e3a972.apk?Signature=LfogW4JuQ7qSS4G8DHM9ugjQqmh5XINBtCdHosltnJabGwL4tWF5T-4NHq6jMOGXl8DfF8YWbzQNZkJ4IemxtNgTjLyvNKTLv4UdEmy0qifx7UBszFouVBEpT4pZkbMQpQAN7LHPpBFO8N3r-qtFhVBnqaqUIl6l-J824LElp4MexilBwTblxQeeKD68X4OPgXbPDUXmRTeypoQ8F9OYSAIX4ZrM1Hwbl2nbJcyL~t9KM4gGw5HK8tOusQja4B5ORkvl~Y1fCOwftvFugnjR37Kga7r52BLOwTj-Ez1dLkKHEi5cPM-tQ0ECC3Ch5QrT~iqFeqU2E~N0ndqqu~5Dmg__&Expires=1590556170&Key-Pair-Id=APKAJRXMMHY3RDXVM6BA";
        break;
    }

    window.open(url, "_blank");
  });
}

function setupFeedbackForm(captchas) {
  const feedbackForm = document.getElementsByClassName("feedback-form")[0];
  const feedbackSubmit = feedbackForm.getElementsByClassName(
    "captcha-button"
  )[0];
  const validationFeedbacks = document.getElementsByClassName(
    "validation-feedback"
  );

  feedbackForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (localStorage.getItem("lastFeedback") === new Date().toDateString()) {
      showSuccessInForm(
        validationFeedbacks[1],
        "You've already submitted a feedback today. Please try again tomorrow."
      );
      feedbackSubmit.disabled = true;
      return;
    }
    if (feedbackForm["feedback"].value === "") {
      showErrorInForm(
        validationFeedbacks[1],
        "Please fill out the field, inspector."
      );
    } else if (captchas.feedback == false) {
      showErrorInForm(
        validationFeedbacks[1],
        "Please complete the captcha, inspector."
      );
      feedbackSubmit.disabled = true;
    } else {
      feedbackSubmit.disabled = true;
      showLoaderInForm(validationFeedbacks[1]);
      let res = await submitFeedback(feedbackForm, validationFeedbacks[1]);
      if (res === true) {
        localStorage.setItem("lastFeedback", new Date().toDateString());
      }
      feedbackSubmit.disabled = res;
    }
  });
}

function setupBugReportForm(captchas) {
  const bugReportForm = document.getElementsByClassName("bug-report-form")[0];
  const bugReportSubmit = bugReportForm.getElementsByClassName(
    "captcha-button"
  )[0];
  const validationFeedbacks = document.getElementsByClassName(
    "validation-feedback"
  );
  const errorCodeRegex = /^[0-9][0-9][0-9]$/;

  bugReportForm.addEventListener("submit", async (event) => {
    event.preventDefault();

    if (localStorage.getItem("lastBugReport") === new Date().toDateString()) {
      showSuccessInForm(
        validationFeedbacks[0],
        "You've already submitted a bug report today. Please try again tomorrow."
      );
      bugReportSubmit.disabled = true;
      return;
    }
    if (
      bugReportForm["title"].value === "" ||
      bugReportForm["description"].value === ""
    ) {
      showErrorInForm(
        validationFeedbacks[0],
        "Please fill out all the required fields, inspector."
      );
    } else if (
      errorCodeRegex.test(bugReportForm["code"].value) === false &&
      bugReportForm["code"].value !== ""
    ) {
      showErrorInForm(
        validationFeedbacks[0],
        "Error codes can only be 3 digits."
      );
      bugReportForm["code"].focus();
    } else if (captchas.bugReport === false) {
      showErrorInForm(
        validationFeedbacks[0],
        "Please complete the captcha, inspector."
      );
      bugReportSubmit.disabled = true;
    } else {
      bugReportSubmit.disabled = true;
      showLoaderInForm(validationFeedbacks[0]);
      let res = await submitBugReport(bugReportForm, validationFeedbacks[0]);
      if (res === true) {
        localStorage.setItem("lastBugReport", new Date().toDateString());
      }
      bugReportSubmit.disabled = res;
    }
  });
}

function showLoaderInForm(indicator) {
  indicator.classList.remove("validation-success");
  indicator.classList.remove("validation-error");
  indicator.innerHTML = `
      <div class="loadingio-spinner-spinner-6b5189sbnoc"><div class="ldio-53svoyay2xi">
<div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div>
</div></div>`;
  indicator.scrollIntoView();
}

function showSuccessInForm(indicator, msg) {
  indicator.classList.remove("validation-error");
  indicator.classList.add("validation-success");
  indicator.innerHTML = msg || "Success! Thank you for submitting.";
  indicator.scrollIntoView();
}

function showErrorInForm(indicator, error) {
  indicator.classList.remove("validation-success");
  indicator.classList.add("validation-error");
  indicator.innerHTML = error;
  indicator.scrollIntoView();
}

async function submitBugReport(form, indicator) {
  try {
    let fb, db, result;
    fb = firebase.app();
    db = firebase.firestore(fb);

    result = await db
      .collection("bug-reports")
      .doc(App.config.version)
      .collection(new Date().toDateString())
      .add({
        title: form["title"].value,
        code: form["code"].value,
        description: form["description"].value,
      })
      .then((_) => {
        showSuccessInForm(indicator, null);
        return true;
      })
      .catch((error) => {
        showErrorInForm(indicator, error);
        return false;
      });

    return result;
  } catch (e) {
    showErrorInForm(
      indicator,
      `An unkown error occurred. Please try again. ${e}`
    );
    return false;
  }
}

async function submitFeedback(form, indicator) {
  try {
    let fb, db, result;
    fb = firebase.app();
    db = firebase.firestore(fb);

    result = await db
      .collection("feedbacks")
      .doc(App.config.version)
      .collection(new Date().toDateString())
      .add({
        feedback: form["feedback"].value,
      })
      .then((_) => {
        showSuccessInForm(indicator, null);
        return true;
      })
      .catch((error) => {
        showErrorInForm(indicator, error);
        return false;
      });

    return result;
  } catch (e) {
    showErrorInForm(indicator, `An unkown error occurred. Please try again.`);
    return false;
  }
}
