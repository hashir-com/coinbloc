abstract class BottomNavState {}

class BottomNavInitial extends BottomNavState {
  final int index;
  BottomNavInitial({this.index = 0});
}

class BottomNavUpdated extends BottomNavState {
  final int index;
  BottomNavUpdated(this.index);
}
