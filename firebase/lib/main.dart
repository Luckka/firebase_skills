import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/firebase_messaging/custom_firebase_messaging.dart';
import 'package:firebase/remote_config/custom_remote_config.dart';
import 'package:firebase/remote_config/custom_visible_rc_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'firebase_auth/auth_interface.dart';
import 'firebase_auth/custom_firebase_auth.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{

  runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await CustomRemoteConfig().initialize();
    await CustomFirebaseMessaging().inicialize(
      callback: () => CustomRemoteConfig().forceFetch()
    );

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    await CustomFirebaseMessaging().getTokenFirebase();


    runApp(const MyApp());

  }, (error,stack) => FirebaseCrashlytics.instance.recordError(error, stack) );

 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const MyHomePage(title: 'home page'),
        '/virtual': (_) => Scaffold(
          appBar: AppBar(),
          body: const SizedBox.expand(
            child: Center(child: Text('Virtual Page')),
          ),
        )
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  final AuthInterface _auth = CustomFirebaseAuth();

  var controllerUser = TextEditingController();
  var controllerPass = TextEditingController();

  String? errorMsg;

  void _incrementCounter() async{
    setState(() => _isLoading = true);
    await CustomRemoteConfig().forceFetch();
     setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomRemoteConfig().getValueOrDefault(
          key: 'isActiveBlue',
          defaultValue: false
        )
          ? Colors.blue
          : Colors.red,
        title: Text(widget.title),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(),)
        : Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.blue.withOpacity(.3),
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    TextFormField(
                      controller: controllerUser,
                      decoration: const InputDecoration(
                        label: Text('Usuario')
                      ),
                    ),
                    TextFormField(
                      controller: controllerPass,
                      decoration: const InputDecoration(
                        label: Text('Senha')
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async{
                        String user = controllerUser.text;
                        String pass = controllerPass.text;
        
                        var result = await _auth.login(user,pass);
                        if(result.isSucess) {
                          setState(() => errorMsg = null);
                          print('Sucess Login');
              
                        }else {
                          setState(() => errorMsg = result.msgError);
                        }
                      },
                       child: const Text('Login')
                    ),
                     ElevatedButton(
                      onPressed: () async{
                        String user = controllerUser.text;
                        String pass = controllerPass.text;
        
                        var result = await _auth.register(user,pass);
                        if(result.isSucess) {
                          setState(() => errorMsg = null);
                          print('Sucess Register');
              
                        }else {
                          setState(() => errorMsg = result.msgError);
                        }
                      },
                       child: const Text('Register')
                    ),
                    if(errorMsg != null) Text(errorMsg!),
                  ],
                ),
              ),
              ElevatedButton(onPressed: () {
                //logica
                FirebaseCrashlytics.instance.log('Ocorreu uma exception manual');
                throw Exception('Erro manual');
              }, child: const Text('Error Crashlytics')),
               Text(
                CustomRemoteConfig().getValueOrDefault(
                  key: 'novaString',
                  defaultValue: 'defaultValue',
                )
                .toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
              CustomVisibleRCWidget(
                rmKey: 'show_container',
                defaultValue: false,
                child: Container(
                  color: Colors.blue,
                  height: 100,
                  width: 100,
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
