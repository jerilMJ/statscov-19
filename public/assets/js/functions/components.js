import { Carousel } from "../components/carousel.js";
import { FolderView } from "../components/folder_view.js";
import { PullTab } from "../components/pull_tab.js";
import { Typewriter } from "../components/typewriter.js";

export function loadFolderViews() {
  const folderViews = document.getElementsByClassName("folder-view");
  const folderViewObjects = [];

  [...folderViews].forEach((folderView) => {
    let folderViewTabs = [
        ...folderView.getElementsByClassName("folder-view-tab"),
      ],
      folderViewContents = [
        ...folderView.getElementsByClassName("folder-view-content"),
      ];

    folderViewObjects.push(
      new FolderView(folderViewTabs, folderViewContents, 0)
    );
  });

  return folderViewObjects;
}

export function showPullTabHandle(pullTab) {
  let height = window.innerHeight;

  if (
    (window.pageYOffset || document.documentElement.scrollTop) > height ||
    !pullTab.isHidden()
  ) {
    pullTab.handle.classList.remove("pull-tab-handle-hidden");
    pullTab.handle.classList.add("pull-tab-handle-visible");
  } else {
    pullTab.handle.classList.remove("pull-tab-handle-visible");
    pullTab.handle.classList.add("pull-tab-handle-hidden");
  }
}

export function loadPullTab() {
  const pullTab = document.getElementsByClassName("pull-tab")[0];
  const overlay = document.getElementsByClassName("full-screen-overlay")[0];

  let pullTabObject, pullTabHandle;

  [...pullTab.children].forEach((child) => {
    if (child.classList.contains("pull-tab-handle")) {
      pullTabHandle = child;
    }
  });

  pullTabObject = new PullTab(
    pullTab,
    window.getComputedStyle(pullTab).getPropertyValue("width"),
    pullTabHandle,
    overlay
  );

  return pullTabObject;
}

export function loadCarousels() {
  const carousels = document.getElementsByClassName("carousel");
  const carouselObjects = [];

  [...carousels].forEach((carousel) => {
    let carouselHead = carousel.getElementsByClassName("carousel-head")[0],
      carouselIndicators = carousel.getElementsByClassName(
        "carousel-indicators"
      )[0],
      carouselLeftNavButton = carousel.getElementsByClassName(
        "carousel-left-nav-button"
      )[0],
      carouselRightNavButton = carousel.getElementsByClassName(
        "carousel-right-nav-button"
      )[0],
      wrappers = carousel.getElementsByClassName("wrapper");

    addRippleListener(carouselLeftNavButton);
    addRippleListener(carouselRightNavButton);

    carouselObjects.push(
      new Carousel(
        carouselHead,
        carouselIndicators,
        carouselLeftNavButton,
        carouselRightNavButton,
        wrappers
      )
    );
  });

  return carouselObjects;
}

function addRippleListener(child) {
  child.addEventListener("click", () => {
    child.classList.remove("ripple");
    setTimeout(() => {
      child.classList.add("ripple");
    }, 10);
  });
}

export function loadTypewriters() {
  const typewriters = document.getElementsByClassName("typewriter");
  const typewriterObjects = [];

  [...typewriters].forEach((typewriter) => {
    const typewriterContentWrapper = typewriter.getElementsByClassName(
      "typewriter-content-wrapper"
    )[0];
    const typewriterContent = typewriter.getElementsByClassName(
      "typewriter-content"
    )[0];
    const typewriterUnderScore = typewriter.getElementsByClassName(
      "typewriter-underscore"
    )[0];

    typewriterObjects.push(
      new Typewriter(
        typewriterContentWrapper,
        typewriterContent,
        "#stay_safe",
        typewriterUnderScore
      )
    );
  });

  return typewriterObjects;
}
