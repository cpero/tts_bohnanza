export class Player {
  color!: string;

  constructor() {}

  toJson() {
    return {
      color: this.color,
    };
  }
}
