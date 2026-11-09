class MealsListData {
  MealsListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals,
    this.Scenes = 0,
    this.imageWidth = 0.0,  // Default width
    this.imageHeight = 0.0, // Default height
  });

  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int Scenes;
  double imageWidth; // Add image width property
  double imageHeight; // Add image height property

  static List<MealsListData> tabIconsList = <MealsListData>[
    MealsListData(
      imagePath: 'assets/cam_icon.png',
      titleTxt: 'Morning Scene',
      Scenes: 10,
      meals: <String>['love scene,', 'action scene,', 'Closing scene'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
      imageWidth: 0.0,  // Add width here
      imageHeight: 0.0, // Add height here
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/lunch.png',
      titleTxt: 'After Noon',
      Scenes: 10,
      meals: <String>['action scene,', 'Closing scene'],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
      imageWidth: 10.0,  // Add width here
      imageHeight: 10.0, // Add height here
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/snack.png',
      titleTxt: 'Evening ',
      Scenes: 3,
      meals: <String>['Closing scene', 'action scene'],
      startColor: '#FE95B6',
      endColor: '#FF5287',
      imageWidth: 10.0,  // Add width here
      imageHeight: 10.0, // Add height here
    ),
    MealsListData(
      imagePath: 'assets/fitness_app/dinner.png',
      titleTxt: 'Night',
      Scenes: 0,
      meals: <String>['No Scene:', 'No Scene'],
      startColor: '#6F72CA',
      endColor: '#1E1466',
      imageWidth: 10.0,  // Add width here
      imageHeight: 10.0, // Add height here
    ),
  ];
}
