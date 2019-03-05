import 'package:flutter/widgets.dart';

import 'package:flutter_graphql/src/graphql_client.dart';
import 'package:flutter_graphql/src/widgets/graphql_provider.dart';

typedef Widget GraphQLConsumerBuilder(GraphQLClient client);

class GraphQLConsumer extends StatelessWidget {
  const GraphQLConsumer({
    final Key key,
    @required this.builder,
    this.client,
  }) : super(key: key);

  final GraphQLConsumerBuilder builder;
  final GraphQLClient client;

  @override
  Widget build(BuildContext context) {
    GraphQLClient tmpClient;
    if (client != null) 
      tmpClient = client;
    else
      tmpClient = GraphQLProvider.of(context).value;
    assert(tmpClient != null);

    return builder(tmpClient);
  }
}
