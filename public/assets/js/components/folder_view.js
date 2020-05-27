export class FolderView {
  constructor(tabs, views, initialTabIndex) {
    this.tabs = tabs;
    this.views = views;

    this.currentTabIndex = initialTabIndex;
    this.previousTabIndex = this.currentTabIndex;

    this.showTab();
    this.setup();
  }

  setup() {
    this.tabs.forEach((tab, index) => {
      tab.addEventListener("click", () => {
        this.previousTabIndex = this.currentTabIndex;
        this.currentTabIndex = index;
        this.showTab();
      });
    });
  }

  showTab() {
    this.tabs[this.previousTabIndex].classList.remove("folder-view-active-tab");
    this.tabs[this.previousTabIndex].classList.add("folder-view-inactive-tab");
    this.tabs[this.currentTabIndex].classList.remove(
      "folder-view-inactive-tab"
    );
    this.tabs[this.currentTabIndex].classList.add("folder-view-active-tab");

    this.views[this.previousTabIndex].classList.remove(
      "folder-view-active-content"
    );
    this.views[this.previousTabIndex].classList.add(
      "folder-view-inactive-content"
    );
    this.views[this.currentTabIndex].classList.remove(
      "folder-view-inactive-content"
    );
    this.views[this.currentTabIndex].classList.add(
      "folder-view-active-content"
    );
  }
}
