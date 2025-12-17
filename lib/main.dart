import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 这个 Widget 是你应用程序的根节点。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 这是你应用程序的主题配置。
        //
        // 试试这个：使用 "flutter run" 运行你的应用程序。你会看到应用程序有一个
        // 紫色的工具栏。然后，在不退出应用的情况下，尝试将下面 colorScheme 中的
        // seedColor 改为 Colors.green，然后触发 "热重载"（保存更改或在
        // Flutter 支持的 IDE 中按下 "热重载" 按钮，如果你是用命令行启动的应用，
        // 则按 "r" 键）。
        //
        // 注意计数器并没有重置为零；应用程序的状态在重载期间不会丢失。
        // 如果要重置状态，请使用热重启（hot restart）。
        //
        // 这对代码也同样有效，不仅仅是值：大多数代码更改都可以通过热重载来测试。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 这个 Widget 是你应用程序的主页。它是有状态的（stateful），意味着它有一个
  // State 对象（定义在下面），该对象包含影响其外观的字段。

  // 这个类是 State 的配置。它保存由父级（在这里是 App widget）提供的值
  // （在这里是 title），并被 State 的 build 方法使用。
  // Widget 子类中的字段总是被标记为 "final"。

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 这个 setState 调用告诉 Flutter 框架这个 State 中有些东西发生了变化，
      // 这会导致它重新运行下面的 build 方法，以便显示可以反映更新后的值。
      // 如果我们在不调用 setState() 的情况下更改 _counter，
      // 那么 build 方法将不会再次被调用，因此看起来什么都不会发生。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 每次调用 setState 时都会重新运行此方法，例如上面的 _incrementCounter 方法。
    //
    // Flutter 框架已经过优化，使得重新运行 build 方法非常快速，
    // 因此你可以直接重建任何需要更新的内容，而不必单独更改 widget 的实例。
    return Scaffold(
      appBar: AppBar(
        // 试试这个：尝试将这里的颜色改为特定颜色（例如 Colors.amber？），
        // 然后触发热重载，看看 AppBar 的颜色变化，而其他颜色保持不变。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 这里我们获取由 App.build 方法创建的 MyHomePage 对象中的值，
        // 并用它来设置我们的 appbar 标题。
        title: Text(widget.title),
      ),
      body: Center(
        // Center 是一个布局 widget。它接受一个子元素并将其定位在父元素的中间。
        child: Column(
          // Column 也是一个布局 widget。它接受一个子元素列表并垂直排列它们。
          // 默认情况下，它会水平方向适应子元素的大小，并尝试在垂直方向上尽可能高。
          //
          // Column 有各种属性来控制其自身大小以及如何定位其子元素。
          // 这里我们使用 mainAxisAlignment 来垂直居中子元素；
          // 这里的主轴是垂直轴，因为 Column 是垂直的（交叉轴将是水平的）。
          //
          // 试试这个：调用 "调试绘制"（在 IDE 中选择 "Toggle Debug Paint" 操作，
          // 或在控制台中按 "p"），查看每个 widget 的线框图。
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 这个尾随逗号使 build 方法的自动格式化更美观。
    );
  }
}
