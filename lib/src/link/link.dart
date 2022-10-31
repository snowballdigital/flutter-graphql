import 'dart:async';

import 'package:flutter_graphql/src/link/fetch_result.dart';
import 'package:flutter_graphql/src/link/operation.dart';

typedef NextLink = Stream<FetchResult> Function(
  Operation operation,
);

typedef RequestHandler = Stream<FetchResult> Function(
  Operation? operation, [
  NextLink? forward,
]);

Link _concat(
  Link first,
  Link second,
) {
  return Link(
      request: first.request == null || second.request == null
          ? null
          : (
              Operation? operation, [
              NextLink? forward,
            ]) {
              return first.request!(operation, (Operation op) {
                return second.request!(op, forward);
              });
            });
}

class Link {
  Link({
    this.request,
  });

  final RequestHandler? request;

  Link concat(Link next) {
    return _concat(this, next);
  }
}

Stream<FetchResult> execute({
  required Link link,
  Operation? operation,
}) {
  return link.request!(operation);
}
