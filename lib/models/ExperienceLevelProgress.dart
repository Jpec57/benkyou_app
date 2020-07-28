class ExperienceLevelProgress {
  int currentLevel;
  int maxLevel;
  int minXp;
  int currentXp;
  int maxXp;

  ExperienceLevelProgress(
      this.currentLevel, this.maxLevel, this.minXp, this.currentXp, this.maxXp);
}

ExperienceLevelProgress getExperienceLevelProgress(
    List<dynamic> levelList, int xp) {
  int i = 0;
  int length = levelList.length;

  for (var level in levelList) {
    if (xp < level["max"] && level["min"] <= xp) {
      return ExperienceLevelProgress(i, length, level["min"], xp, level["max"]);
    }
    i++;
  }
  return ExperienceLevelProgress(-1, length, 0, 0, 2147483647);
}

const VOCAB_EXPERIENCE_LEVELS = [
  {
    "min": 0,
    "max": 100,
  },
  {
    "min": 100,
    "max": 500,
  },
  {
    "min": 500,
    "max": 1000,
  },
  {
    "min": 1000,
    "max": 5000,
  },
  {
    "min": 5000,
    "max": 10000,
  },
  {
    "min": 10000,
    "max": 20000,
  },
  {
    "min": 20000,
    "max": 40000,
  },
  {
    "min": 40000,
    "max": 65536,
  },
  {
    "min": 65536,
    "max": 70000,
  },
  {
    "min": 70000,
    "max": 100000,
  },
  {
    "min": 100000,
    "max": 2147483647,
  },
];
