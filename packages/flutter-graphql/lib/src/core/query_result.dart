import 'package:flutter_graphql/src/core/graphql_error.dart';
import 'package:flutter_graphql/src/core/network_status.dart';

enum FetchType {
  normal,
  refetch,
  poll,
}

class QueryResult {

  QueryResult({
    this.data,
    this.errors,
    this.loading,
    this.networkStatus,
    this.stale,
  });

  /// List<dynamic> or Map<String, dynamic>
  dynamic data;
  List<GraphQLError> errors;
  bool loading;
  bool stale;
  NetworkStatus networkStatus;

  bool get hasErrors {
    if (errors == null) {
      return false;
    }

    return errors.isNotEmpty;
  }

  void addError(GraphQLError graphQLError) {
    if (errors != null) {
      errors.add(graphQLError);
    } else {
      errors = <GraphQLError>[graphQLError];
    }
  }
}