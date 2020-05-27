import { setupForms } from "./functions/forms.js";
import * as components from "./functions/components.js";
import { App } from "./utils/app.js";

window.onload = function () {
  document.getElementById("load").style.opacity = "0";
  setTimeout(() => {
    document.getElementById("load").style.display = "none";
  }, 1000);
  document.getElementById("main-page").style.display = "block";
};

document.addEventListener("DOMContentLoaded", () => {
  let carousels = [],
    pullTab,
    folderViews = [],
    typewriters = [];

  let captchas = {
    bugReport: false,
    feedback: false,
  };

  document.getElementsByClassName("version")[0].innerHTML = App.config.version;

  carousels = components.loadCarousels();
  pullTab = components.loadPullTab();
  folderViews = components.loadFolderViews();
  typewriters = components.loadTypewriters();
  setupForms(captchas);

  window.onscroll = function () {
    components.showPullTabHandle(pullTab);
  };

  window.onresize = function () {
    // re-calibrate pull-tab
    pullTab.pullTab.style.width = "80vw";
    pullTab.width = window
      .getComputedStyle(pullTab.pullTab)
      .getPropertyValue("width");

    // re-calibrate carousels
    carousels.forEach((carousel) => {
      carousel.width = window
        .getComputedStyle(carousel.wrappers[0])
        .getPropertyValue("width");
    });
  };

  const feedbackSubmit = document.getElementById("feedback-button");
  const bugReportSubmit = document.getElementById("bug-report-button");

  window.bugReportRecaptchaSuccess = async function (token) {
    const result = await getRecaptchaResult(token);
    console.log(result.success);
    if (result.data.success) enableBugReportSubmit();
  };

  window.feedbackRecaptchaSuccess = async function (token) {
    const result = await getRecaptchaResult(token);
    if (result.data.success) enableFeedbackSubmit();
  };

  window.enableBugReportSubmit = function () {
    captchas.bugReport = true;
    bugReportSubmit.disabled = false;
  };

  window.enableFeedbackSubmit = function () {
    captchas.feedback = true;
    feedbackSubmit.disabled = false;
  };

  window.disableFeedbackSubmit = function () {
    captchas.feedback = false;
    feedbackSubmit.disabled = true;
  };

  window.disableBugReportSubmit = function () {
    captchas.bugReport = false;
    bugReportSubmit.disabled = true;
  };
});

async function getRecaptchaResult(token) {
  const sendToken = firebase.functions().httpsCallable("sendUserResponseToken");
  const result = await sendToken(token);
  return result;
}
