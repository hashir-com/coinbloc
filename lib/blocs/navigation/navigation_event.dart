abstract class BottomNavEvent {}

class ChangeTab extends BottomNavEvent {
  final int index;
  ChangeTab(this.index);
}
