import 'package:Shrine/login.dart';
import 'package:Shrine/model/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget {
  final Category currentCategory;
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;

  Backdrop(
      {@required this.currentCategory,
      @required this.frontLayer,
      @required this.backLayer,
      @required this.frontTitle,
      @required this.backTitle})
      : assert(currentCategory != null),
        assert(frontLayer != null),
        assert(backLayer != null),
        assert(frontTitle != null),
        assert(backTitle != null);

  @override
  _BackdropState createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _controller;

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 48.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    Animation<RelativeRect> layerAnimation = RelativeRectTween(
            begin: RelativeRect.fromLTRB(
                0.0, layerTop, 0.0, layerTop - layerSize.height),
            end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0))
        .animate(_controller.view);

    return Stack(
      key: _backdropKey,
      children: [
        ExcludeSemantics(
            excluding: _frontLayerVisible, child: widget.backLayer),
        PositionedTransition(
            rect: layerAnimation,
            child: _FrontLayer(
              child: widget.frontLayer,
              onTap: _toggleBackdropLayerVisibility,
            ))
      ],
    );
  }

  @override
  void didUpdateWidget(covariant Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentCategory != oldWidget.currentCategory) {
      _toggleBackdropLayerVisibility();
    } else if (!_frontLayerVisible) {
      _controller.fling(velocity: _kFlingVelocity);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: 300), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
        brightness: Brightness.light,
        elevation: 0,
        titleSpacing: 0,
        title: _BackdropTitle(
          listenable: _controller.view,
          onPress: _toggleBackdropLayerVisibility,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.lock_open_outlined,
                semanticLabel: 'login',
              ),
              onPressed: () {
                print('Login button');
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
              }),
          IconButton(
              icon: Icon(
                Icons.tune,
                semanticLabel: 'filter',
              ),
              onPressed: () {
                print('Filter button');
              }),
        ]);
    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: _buildStack,
      ),
    );
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    _controller.fling(
        velocity: _frontLayerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }
}

class _FrontLayer extends StatelessWidget {
  const _FrontLayer({Key key, this.child, this.onTap}) : super(key: key);
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: child)],
        ),
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {
  final Function onPress;
  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle(
      {Key key,
      Listenable listenable,
      this.onPress,
      @required this.frontTitle,
      @required this.backTitle})
      : assert(frontTitle != null),
        assert(backTitle != null),
        super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;

    return DefaultTextStyle(
        style: Theme.of(context).primaryTextTheme.headline6,
        child: Row(
          children: [
            SizedBox(
              width: 72.0,
              child: IconButton(
                padding: EdgeInsets.only(right: 8.0),
                onPressed: this.onPress,
                icon: Stack(
                  children: [
                    Opacity(
                      opacity: animation.value,
                      child: ImageIcon(AssetImage('assets/slanted_menu.png')),
                    ),
                    FractionalTranslation(
                      translation: Tween<Offset>(
                        begin: Offset.zero,
                        end: Offset(1.0, 0.0),
                      ).evaluate(animation),
                      child: ImageIcon(AssetImage('assets/diamond.png')),
                    )
                  ],
                ),
              ),
            ),
            Stack(
              children: [
                Opacity(
                  opacity: CurvedAnimation(
                    parent: ReverseAnimation(animation),
                    curve: Interval(0.5, 1.0)
                  ).value,
                  child: FractionalTranslation(
                    translation: Tween<Offset>(
                      begin: Offset.zero,
                      end: Offset(0.5, 0.0),
                    ).evaluate(animation),
                    child: backTitle,
                  ),
                ),
                Opacity(
                  opacity: CurvedAnimation(
                      parent: animation,
                      curve: Interval(0.5, 1.0)
                  ).value,
                  child: FractionalTranslation(
                    translation: Tween<Offset>(
                      begin: Offset(-0.25, 0.0),
                      end: Offset.zero,
                    ).evaluate(animation),
                    child: frontTitle,
                  ),
                )
              ],
            )
          ],
        )
    );
  }
}
