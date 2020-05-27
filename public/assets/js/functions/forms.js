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

  const fdroidBtn = document.getElementById("fdroid");
  const megaBtn = document.getElementById("mega");
  const xdaBtn = document.getElementById("xda");

  [fdroidBtn, megaBtn, xdaBtn].forEach((btn, index) => {
    btn.addEventListener("click", (event) => {
      event.preventDefault();
      let url;

      switch (androidDownloadForm["cpu-architecture"].value) {
        case "arm-32-bit":
          url =
            index === 0
              ? "a"
              : index === 1
              ? "https://mega.nz/folder/3PBmBYLB#FcpJAy2qRJ64-Ouu8uOzbw/file/KaRRQCJR"
              : "https://labs.xda-developers.com/store/app/io.github.jerilmj.statscov_19";
          break;
        case "arm-64-bit":
          url =
            index === 0
              ? "a"
              : index === 1
              ? "https://mega.nz/folder/3PBmBYLB#FcpJAy2qRJ64-Ouu8uOzbw/file/jfJDwIaA"
              : "https://labs.xda-developers.com/store/app/io.github.jerilmj.statscov_19";
          break;
        case "x86-64-bit":
          url =
            index === 0
              ? "a"
              : index === 1
              ? "https://mega.nz/folder/3PBmBYLB#FcpJAy2qRJ64-Ouu8uOzbw/file/beQjjKYJ"
              : "https://labs.xda-developers.com/store/app/io.github.jerilmj.statscov_19";
          break;
        case "idk":
          url =
            index === 0
              ? "a"
              : index === 1
              ? "https://mega.nz/folder/3PBmBYLB#FcpJAy2qRJ64-Ouu8uOzbw/file/beJz2CzZ"
              : "https://labs.xda-developers.com/store/app/io.github.jerilmj.statscov_19";
          break;
      }

      window.open(url, "_blank");
    });
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
