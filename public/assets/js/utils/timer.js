export class Timer {
  constructor(fn, time) {
    this.timer = setInterval(fn, time);
    this.fn = fn;
    this.time = time;
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }

    return this;
  }

  start() {
    if (!this.timer) {
      this.stop();
      this.timer = setInterval(this.fn, this.time);
    }
    return this;
  }

  reset(fn, time = this.time) {
    this.fn = fn;
    this.time = time;
    this.stop();
    return this.start();
  }
}
