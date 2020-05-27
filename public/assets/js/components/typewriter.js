import { Timer } from "../utils/timer.js";

export class Typewriter {
  constructor(contentWrapper, content, sentence, underscore) {
    this.contentWrapper = contentWrapper;
    this.content = content;
    this.sentence = sentence;
    this.underscore = underscore;
    this.currentText = "";
    this.currentIndex = 0;
    this.times = [600, 800, 1000, 1200, 1400];

    this.setup();
    this.type();
  }

  setup() {
    this.typeFunction = function () {
      if (this.currentIndex + 1 <= this.sentence.length + 1) {
        this.currentText = this.sentence.slice(0, this.currentIndex++);
      } else {
        this.currentText = "";
        this.currentIndex = 0;
      }
      this.type();
    }.bind(this);

    this.timer = new Timer(this.typeFunction, 500);

    this.blink = new Timer(() => {
      if (this.underscore.style.opacity === "0") {
        this.underscore.style.opacity = "1";
      } else {
        this.underscore.style.opacity = "0";
      }
    }, 530);

    this.blink.start();
    this.timer.start();
  }

  type() {
    this.content.innerHTML = this.currentText;

    if (this.content.innerHTML == this.sentence) {
      setTimeout(() => {
        this.contentWrapper.classList.add("selected");
      }, this.getRandomTime());

      this.timer.reset(this.typeFunction, this.getRandomTime() + 1000);
    } else {
      this.contentWrapper.classList.remove("selected");
      this.timer.reset(this.typeFunction, this.getRandomTime());
    }
  }

  getRandomTime() {
    return this.times[Math.floor(Math.random() * this.times.length)];
  }
}
