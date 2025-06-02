abstract class ListItem {
  Object get itemId;
}

class HeaderItem extends ListItem {
  final String title;

  HeaderItem(this.title);

  @override
  Object get itemId => 'header-$title';
}
