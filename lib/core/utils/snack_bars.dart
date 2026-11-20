/// How long the bar shown after an archive / delete action stays on screen
/// before hiding by itself (REMARKS #150). Bars with an "Undo" action must
/// also pass `persist: false` — since Flutter 3.35 a SnackBar with an action
/// otherwise stays until it's dismissed by hand.
const kActionSnackBarDuration = Duration(seconds: 3);
