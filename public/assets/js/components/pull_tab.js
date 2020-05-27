export class PullTab {
  constructor(pullTab, width, handle, overlay) {
    this.handle = handle;
    this.pullTab = pullTab;
    this.width = width;
    this.overlay = overlay;

    this.setup();
  }

  setup() {
    this.pullTab.style.transform = `translateX(${this.width})`;

    this.handle.addEventListener("click", () => {
      this.toggle();
    });

    this.overlay.addEventListener("click", () => {
      this.handle.style.opacity = "0.5";
      this.pullTab.classList.remove("pull-tab-shadow");
      this.pullTab.style.transform = `translateX(80vw)`;
      this.overlay.classList.remove("full-screen-overlay-active");
    });
  }

  toggle() {
    if (!this.isHidden()) {
      this.handle.style.opacity = "0.5";
      this.pullTab.classList.remove("pull-tab-shadow");
      this.pullTab.style.transform = `translateX(80vw)`;
      this.overlay.classList.remove("full-screen-overlay-active");
    } else {
      this.pullTab.style.transform = "translateX(0)";
      this.pullTab.classList.add("pull-tab-shadow");
      this.handle.style.opacity = "1";
      this.overlay.classList.add("full-screen-overlay-active");
    }
  }

  isHidden() {
    return (
      this.pullTab.style.transform === `translateX(${this.width})` ||
      this.pullTab.style.transform === `translateX(80vw)` ||
      window.getComputedStyle(this.pullTab).getPropertyValue("transform") ===
        `matrix(1, 0, 0, 1, ${this.width.replace("px", "")}, 0)`
    );
  }
}
