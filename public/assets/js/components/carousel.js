import { Timer } from "../utils/timer.js";

export class Carousel {
  constructor(head, indicators, leftNavButton, rightNavButton, wrappers) {
    this.head = head;
    this.initialX = 0;
    this.finalX = 0;
    this.totalSlides = this.head.children.length;
    this.currentSlide = 0;
    this.previousSlide = this.totalSlides - 1;
    this.slideDist = 50;
    this.indicators = indicators;
    this.dots = "";
    this.leftNavButton = leftNavButton;
    this.rightNavButton = rightNavButton;
    this.wrappers = wrappers;
    this.width = window.getComputedStyle(wrappers[0]).getPropertyValue("width");
    this.init();
  }

  init() {
    this.hideAll();
    this.showWrapper();

    this.timer = new Timer(this.slideLeft.bind(this), 5000);
    this.timer.start();

    this.leftNavButton.addEventListener("click", () => {
      this.slideRight();
      this.timer.reset(this.slideRight.bind(this));
    });

    this.rightNavButton.addEventListener("click", () => {
      this.slideLeft();
      this.timer.reset(this.slideLeft.bind(this));
    });

    this.buildIndicators();
    this.implementMouseSwipe();
    this.implementTouchSwipe();
    this.indicate();
  }

  buildIndicators() {
    for (let i = 0; i < this.totalSlides; i++) {
      this.dots += "<div class='carousel-indicator'></div>";
    }
    this.indicators.innerHTML = this.dots;

    for (const [index, indicator] of [...this.indicators.children].entries()) {
      indicator.addEventListener("click", () => {
        this.slideTo(index);
      });
    }
  }

  implementMouseSwipe() {
    this.head.addEventListener("mousedown", (event) => {
      this.initialX = event.screenX;
    });

    this.head.addEventListener("mouseup", (event) => {
      this.finalX = event.screenX;
      this.handleGesture();
    });
  }

  implementTouchSwipe() {
    this.head.addEventListener("touchstart", (event) => {
      this.initialX = event.touches[0].screenX;
      this.finalX = this.initialX;
    });

    this.head.addEventListener("touchmove", (event) => {
      this.finalX = event.touches[0].screenX;
    });

    this.head.addEventListener("touchend", (event) => {
      this.handleGesture();
    });
  }

  handleGesture() {
    // slide left i.e, swipe from right to left
    if (this.initialX - this.finalX > this.slideDist) {
      this.slideLeft();
      this.timer.reset(this.slideLeft.bind(this));
    }
    // slide right i.e, swipe from left to right
    else if (this.initialX - this.finalX < -this.slideDist) {
      this.slideRight();
      this.timer.reset(this.slideRight.bind(this));
    }
  }

  slideRight() {
    this.previousSlide = this.currentSlide;
    if (this.currentSlide > 0) {
      this.currentSlide--;
      this.slide();
    } else {
      this.currentSlide = this.totalSlides - 1;
      this.boundarySlide();
    }
    this.indicate();
  }

  slideLeft() {
    this.previousSlide = this.currentSlide;
    if (this.currentSlide < this.totalSlides - 1) {
      this.currentSlide++;
      this.slide();
    } else {
      this.currentSlide = 0;
      this.boundarySlide();
    }
    this.indicate();
  }

  slideTo(slide) {
    if (slide == this.currentSlide) {
      return;
    }
    this.previousSlide = this.currentSlide;
    this.currentSlide = slide;

    if (
      (this.currentSlide == 0 && this.previousSlide == this.totalSlides - 1) ||
      (this.currentSlide == this.totalSlides - 1 && this.previousSlide == 0)
    ) {
      this.boundarySlide();
    } else {
      this.slide();
    }

    this.indicate();
    if (this.previousSlide < this.currentSlide) {
      this.timer.reset(this.slideLeft.bind(this));
    } else {
      this.timer.reset(this.slideRight.bind(this));
    }
  }

  // indicate what slide is currently being moved
  indicate() {
    this.indicators.children[this.previousSlide].classList.remove(
      "carousel-indicator-active"
    );
    this.indicators.children[this.currentSlide].classList.add(
      "carousel-indicator-active"
    );
  }

  // if current slide is boundary slide (i.e, at either end),
  // fade it then un-fade once the correct slide is in place
  boundarySlide() {
    this.head.style.opacity = "0";
    setTimeout(() => {
      this.head.style.transition =
        "transform 0.5s ease-in, opacity 0.5s ease-in";
      this.slide();
      setTimeout(() => {
        this.head.style.transition =
          "transform 1s ease-in, opacity 0.5s ease-in";
        this.head.style.opacity = "1";
      }, 500);
    }, 500);
  }

  slide() {
    this.hideAll();
    this.showWrapper();

    this.head.style.transform = `translateX(${
      -this.currentSlide * this.width.replace("px", "")
    }px)`;
  }

  hideAll() {
    [...this.wrappers].forEach((wrapper) => {
      wrapper.classList.remove("vis");
      wrapper.classList.add("invis");
    });
  }

  showWrapper() {
    this.wrappers[this.currentSlide].style.visibility = "visible";
    this.wrappers[this.currentSlide].classList.remove("invis");
    this.wrappers[this.currentSlide].classList.add("vis");
  }
}
