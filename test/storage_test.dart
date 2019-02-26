@TestOn('node')
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/fs.dart';
import 'package:test/test.dart';

import 'setup.dart';

// to run a particular test, use (eg): 
// > pub run build_runner test -- -n "deleteFile" 
// https://pub.dartlang.org/packages/build_runner 
// https://github.com/dart-lang/build/blob/master/docs/getting_started.md 


void main() {
  group('Storage', () {
    App app;

    setUpAll(() async {
      app = initFirebaseApp();
    });

    tearDownAll(() {
      return app.delete();
    });

    test('uploadFile', () async {
      var readable = fs.createReadStream('/Users/nick/Desktop/test.jpg');
      await app.storage().bucket("crowdleaguetest.appspot.com").file("test.jpg").upload(readable);
    });

    test('deleteFile', () async {
      
      print("creating File object with name: 'test.jpg'"); 
      File file = app.storage().bucket("crowdleaguetest.appspot.com").file("test.jpg");

      print("checking if file already exists...");
      List<bool> existsList = await file.exists();
      if(!existsList.elementAt(0)) {
        print("file does not exist, uploading...");
        // upload a file for deletion 
        var readable = fs.createReadStream('/Users/nick/Desktop/test.jpg');
        await file.upload(readable);
        print("uploaded.");
      }
      else {
        print("file already exists, no need to upload.");
      }
      
      print("attempting delete..."); 
      var result = await app.storage().bucket("crowdleaguetest.appspot.com").file("test.jpg").delete();
      var response = result.elementAt(1);
      print("deleted.");
      expect(response.statusCode, 204);

    });

    // TODO: test what happens under various error scenarios (eg for delete) - is the error in the Response object or thrown? 

    test('checkBucketExists', () async {

      var result = await app.storage().bucket("crowdleaguetest.appspot.com").exists();
      print(result);

    });

    // test('firestoreTest', () async {

    //   var result = await app.firestore()
    //   print(result);

    // });

    // test('checkBucketExists', () async {
      // var completer = new Completer();
      // Promise p = app.storage().bucket("crowdleaguetest.appspot.com").exists();
      // p.then(
      //   (value) {
      //     print(value);
      //     completer.complete();
      //   },
      //   (error) {
      //     print(error);
      //     completer.complete();
      //   });
      // await completer.future;
      // expect(false, false);  
    // });
    
  });
}
