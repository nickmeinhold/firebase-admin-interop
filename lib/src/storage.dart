import 'dart:async';

import 'package:meta/meta.dart';
import 'package:node_interop/util.dart';
import 'package:node_interop/stream.dart';

import 'bindings.dart' as js;

/// Represents a GCS client and is the entry point for all
/// Storage operations.
class Storage {

  /// JavaScript Storage object wrapped by this instance.
  @protected
  final js.Storage nativeInstance;

  /// Creates new Storage client which wraps [nativeInstance].
  Storage(this.nativeInstance);

  Bucket bucket([String path]) {
    return Bucket(nativeInstance.bucket(path), this);
  }

}

/// A Bucket object can be used for 
class Bucket {
  Bucket(this.nativeInstance, this.storage);

  @protected
  final js.Bucket nativeInstance;
  final Storage storage;

  // the only safe route is to always assume that generic type arguments are not supplied (i.e. are bound to dynamic)
  // and use conversions and casts in wrapper code where desired
  //   - https://github.com/matanlurey/dart_js_interop#generic-type-arguments
  // use from rather than retype or cast: https://github.com/dart-lang/site-www/issues/736#issuecomment-383208294
  //   - anyway looks like retype has replaced cast and cast has been removed (read further down in above link) 
  Future<List<bool>> exists() {
    return promiseToFuture<List<dynamic>>(nativeInstance.exists()).then((val) => List<bool>.from(val));
  }

  File file(String name) {
    return File(nativeInstance.file(name));
  }
  
}

/// A File object can be used for 
/// https://cloud.google.com/nodejs/docs/reference/storage/2.3.x/File
/// https://github.com/googleapis/nodejs-storage
class File {

  // File(bucket, name, options) 
  File(this.nativeInstance);

  @protected
  final js.StorageFile nativeInstance;

  Future<List<bool>> exists() {
    return promiseToFuture<List<dynamic>>(nativeInstance.exists()).then((val) => List<bool>.from(val));
  }

  // I have attempted to provide the response in a form as close to the js lib as possible 
  // The Response object has minimal members mapped, but returning a List (array) of Response objects is what the js lib does 
  Future<List<js.Response>> delete() {
    return promiseToFuture<List<dynamic>>(nativeInstance.delete()).then((val) => List<js.Response>.from(val));
  }

  // need to add CreateWriteStreamOptions 
  Writable createWriteStream([options]) {
    return this.nativeInstance.createWriteStream();
  }

  Future<void> upload(Readable readable) {
    var completer = Completer(); 
    readable.pipe(this.createWriteStream())
      .on('error', (err) => completer.completeError(err))
      .on('finish', () => completer.complete());
    return completer.future;
  }

}
