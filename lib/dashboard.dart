import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/profi.dart';
import 'dbpath.dart';
import 'reg.dart';
import 'transition_route_observer.dart';
import 'widgets/round_button.dart';

class DashboardScreen extends StatefulWidget {
  var data;
  String url;
  List oyo;
  bool la;
  String? sumc;
  String? rankc ;
  LocationData? _locationData;
    int blocked;

  DashboardScreen(this.data,this.url, this.oyo,this.la,this.sumc ,this.rankc,this._locationData,this.blocked );

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, TransitionRouteAware {
  final routeObserver = TransitionRouteObserver<PageRoute?>();
  static const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);
  late Animation<double> _headerScaleAnimation;
  AnimationController? _loadingController;

  @override
  void initState() {

    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );

    _headerScaleAnimation =
        Tween<double>(begin: .6, end: 1).animate(CurvedAnimation(
      parent: _loadingController!,
      curve: headerAniInterval,
    ));
    _loadingController!.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
        this, ModalRoute.of(context) as PageRoute<dynamic>?);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _loadingController!.dispose();
    super.dispose();
  }



  Widget _buildButton(
      {Widget? icon, String? label, required Interval interval, onTap}) {
    return RoundButton(
      icon: icon,
      label: label,
      loadingController: _loadingController,
      interval: Interval(
        interval.begin,
        interval.end,
        curve: ElasticOutCurve(0.42),
      ),
      onPressed: () => onTap(),
    );
  }

  Widget _buildDashboardGrid() {
    const step = 0.04;
    const aniInterval = 0.75;

    return GridView.count(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 20,
      ),
      childAspectRatio: .9,
      // crossAxisSpacing: 5,
      crossAxisCount: 2,
      children: [
        Hero(
          tag: 'hero-rectangle',
          child: _buildButton(
            icon: Icon(FontAwesomeIcons.user),
            label: widget.la==false?'Profile':'حسابي',
            interval: Interval(0, aniInterval),
            onTap: () => _gotoDetailsPage(context),
          ),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.handHoldingUsd),
          label: widget.la==false? 'Offers' : " العروض",
          interval: Interval(step * 2, aniInterval + step * 2),
          onTap: () => PayPage(context),
       
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.chartLine),
          label: widget.la==false?'Report':"تقييم العملاء",
          interval: Interval(0, aniInterval),
          onTap: () => ReporPage(context),
        ),
        _buildButton(
          icon: Icon(FontAwesomeIcons.history),
          label: widget.la==false?'History':"طلباتي",
          interval: Interval(step * 2, aniInterval + step * 2),
          onTap: () => _gotoHistoryPage(context),
        ),
         _buildButton(
          icon: Icon(FontAwesomeIcons.eraser),
          label: widget.la==false?'' :'',
          interval: Interval(0, aniInterval),
          onTap: () {},
        ),
         _buildButton(
          icon: Icon(FontAwesomeIcons.comment),
          label: widget.la==false?'Evaluation Requests' : "طلبات التقييم",
          interval: Interval(0, aniInterval),
          onTap: () => Offers(context),
        ),
        // _buildButton(
        //   icon: Icon(FontAwesomeIcons.slidersH, size: 20),
        //   label: 'Settings',
        //   interval: Interval(step * 2, aniInterval + step * 2),
        // ),
        // _buildButton(
        //   icon: Icon(FontAwesomeIcons.ellipsisH),
        //   label: 'Other',
        //   interval: Interval(0, aniInterval),
        // ),
     
      ],
    );
  }



  void _gotoDetailsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(body: ProfilePage(widget.data,widget.url,widget.oyo,widget.la,widget.sumc,widget.rankc)),
    ));
  }
    void _gotoHistoryPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(body: HistPage(widget.oyo,widget.url,widget.la)),
    ));
  }
    void PayPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(body: PayMePage(widget.data,widget.url,widget.la,)),
    ));
  }
     void ReporPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(body: ReportPage(widget.oyo,widget.la)),
    ));
  }
    void Offers(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => Scaffold(body: OffersOrders(widget.data,widget.la,widget._locationData,widget.blocked)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
      home:SafeArea(
      child: Scaffold(
       
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.clamp,
                          colors: <Color>[
                            Colors.grey.shade100,
                            // Colors.deepPurple.shade100,
                            // Colors.deepPurple.shade100,
                            // Colors.deepPurple.shade100,
                            // Colors.red,
                            Colors.pink,
                          ],
                        ).createShader(bounds);
                      },
                      child: _buildDashboardGrid(),
                    ),
                  ),
                ],
              ),
              // if (!kReleaseMode) _buildDebugButtons(),
            ],
          ),
        ),
      ),
    ));
  }
}
