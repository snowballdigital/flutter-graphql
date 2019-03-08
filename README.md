# Flutter GraphQL

[![version][version-badge]][package]
[![MIT License][license-badge]][license]
[![All Contributors](https://img.shields.io/badge/all_contributors-15-orange.svg?style=flat-square)](#contributors)
[![PRs Welcome][prs-badge]](http://makeapullrequest.com)

[![Watch on GitHub][github-watch-badge]][github-watch]
[![Star on GitHub][github-star-badge]][github-star]

## Table of Contents

- [Flutter GraphQL](#flutter-graphql)
  - [Table of Contents](#table-of-contents)
  - [About this project](#about-this-project)
  - [Installation](#installation)
  - [Usage](#usage)
    - [GraphQL Provider](#graphql-provider)
    - [Offline Cache](#offline-cache)
      - [Normalization](#normalization)
    - [Queries](#queries)
    - [Mutations](#mutations)
    - [Subscriptions (Experimental)](#subscriptions-experimental)
    - [Graphql Consumer](#graphql-consumer)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [New Contributors](#new-contributors)
  - [Founding Contributors](#founding-contributors)

## About this project

GraphQL brings many benefits, both to the client: devices will need less requests, and therefore reduce data useage. And to the programer: requests are arguable, they have the same structure as the request.

This project combines the benefits of GraphQL with the benefits of `Streams` in Dart to deliver a high performace client.

The project took inspriation from the [Apollo GraphQL client](https://github.com/apollographql/apollo-client), great work guys!

**Note: Still in alpha**

**Docs is coming soon**

## Installation

First depend on the library by adding this to your packages `pubspec.yaml`:

```yaml
dependencies:
  flutter_graphql: ^1.0.0-alpha
```

Now inside your Dart code you can import it.

```dart
import 'package:flutter_graphql/flutter_graphql.dart';
```

## Usage

To use the client it first needs to be initialized with an link and cache. For this example we will be uing an `HttpLink` as our link and `InMemoryCache` as our cache. If your endpoint requires authentication you can provide some custom headers to `HttpLink`.

> For this example we will use the public GitHub API.

```dart
...

import 'package:flutter_graphql/flutter_graphql.dart';

void main() {
  HttpLink link = HttpLink(
    uri: 'https://api.github.com/graphql',
    headers: <String, String>{
      'Authorization': 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
    },
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );

  ...
}

...
```

### GraphQL Provider

In order to use the client, you `Query` and `Mutation` widgets to be wrapped with the `GraphQLProvider` widget.

> We recommend wrapping your `MaterialApp` with the `GraphQLProvider` widget.

```dart
  ...

  return GraphQLProvider(
    client: client,
    child: MaterialApp(
      title: 'Flutter Demo',
      ...
    ),
  );

  ...
```

### Offline Cache

The in-memory cache can automatically be saved to and restored from offline storage. Setting it up is as easy as wrapping your app with the `CacheProvider` widget.

> It is required to place the `CacheProvider` widget is inside the `GraphQLProvider` widget, because `GraphQLProvider` makes client available trough the build context.

```dart
...

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MaterialApp(
          title: 'Flutter Demo',
          ...
        ),
      ),
    );
  }
}

...
```

#### Normalization
To enable [apollo-like normalization](https://www.apollographql.com/docs/react/advanced/caching.html#normalization), use a `NormalizedInMemoryCache`:
```dart
ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    cache: NormalizedInMemoryCache(
      dataIdFromObject: typenameDataIdFromObject,
    ),
    link: link,
  ),
);
```
`dataIdFromObject` is required and has no defaults. Our implementation is similar to apollo's, requiring a function to return a universally unique string or `null`. The predefined `typenameDataIdFromObject` we provide is similar to apollo's default:
```dart
String typenameDataIdFromObject(Object object) {
  if (object is Map<String, Object> &&
      object.containsKey('__typename') &&
      object.containsKey('id')) {
    return "${object['__typename']}/${object['id']}";
  }
  return null;
}
```
However note that **`flutter-graphql` does not inject __typename into operations** the way apollo does, so if you aren't careful to request them in your query, this normalization scheme is not possible.


### Queries

Creating a query is as simple as creating a multiline string:

```dart
String readRepositories = """
  query ReadRepositories(\$nRepositories) {
    viewer {
      repositories(last: \$nRepositories) {
        nodes {
          id
          name
          viewerHasStarred
        }
      }
    }
  }
"""
    .replaceAll('\n', ' ');
```

In your widget:

```dart
...

Query(
  options: QueryOptions(
    document: readRepositories, // this is the query string you just created
    variables: {
      'nRepositories': 50,
    },
    pollInterval: 10,
  ),
  builder: (QueryResult result) {
    if (result.errors != null) {
      return Text(result.errors.toString());
    }

    if (result.loading) {
      return Text('Loading');
    }

    // it can be either Map or List
    List repositories = result.data['viewer']['repositories']['nodes'];

    return ListView.builder(
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repository = repositories[index];

        return Text(repository['name']);
    });
  },
);

...
```

### Mutations

Again first create a mutation string:

```dart
String addStar = """
  mutation AddStar(\$starrableId: ID!) {
    addStar(input: {starrableId: \$starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
"""
    .replaceAll('\n', ' ');
```

The syntax for mutations is fairly similar to that of a query. The only diffence is that the first argument of the builder function is a mutation function. Just call it to trigger the mutations (Yeah we deliberately stole this from react-apollo.)

```dart
...

Mutation(
  options: MutationOptions(
    document: addStar, // this is the mutation string you just created
  ),
  builder: (
    RunMutation runMutation,
    QueryResult result,
  ) {
    return FloatingActionButton(
      onPressed: () => runMutation({
        'starrableId': <A_STARTABLE_REPOSITORY_ID>,
      }),
      tooltip: 'Star',
      child: Icon(Icons.star),
    );
  },
);

...
```

### Subscriptions (Experimental)

The syntax for subscriptions is again similar to a query, however, this utilizes WebSockets and dart Streams to provide real-time updates from a server.
Before subscriptions can be performed a global intance of `socketClient` needs to be initialized.

> We are working on moving this into the same `GraphQLProvider` stucture as the http client. Therefore this api might change in the near future.

```dart
socketClient = await SocketClient.connect('ws://coolserver.com/graphql');
```

Once the `socketClient` has been initialized it can be used by the `Subscription` `Widget`

```dart
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Subscription(
          operationName,
          query,
          variables: variables,
          builder: ({
            bool loading,
            dynamic payload,
            dynamic error,
          }) {
            if (payload != null) {
              return Text(payload['requestSubscription']['requestData']);
            } else {
              return Text('Data not found');
            }
          }
        ),
      )
    );
  }
}
```

### Graphql Consumer

You can always access the client direcly from the `GraphQLProvider` but to make it even easier you can also use the `GraphQLConsumer` widget.

```dart
  ...

  return GraphQLConsumer(
    builder: (GraphQLClient client) {
      // do something with the client

      return Container(
        child: Text('Hello world'),
      );
    },
  );

  ...
```

## Roadmap

This is currently our roadmap, please feel free to request additions/changes.

| Feature                 | Progress |
| :---------------------- | :------: |
| Queries                 |    ✅    |
| Mutations               |    ✅    |
| Subscriptions           |    ✅    |
| Query polling           |    ✅    |
| In memory cache         |    ✅    |
| Offline cache sync      |    ✅    |
| Optimistic results      |    🔜    |
| Client state management |    🔜    |
| Modularity              |    🔜    |
| Documentation      |    🔜    |

## Contributing

Feel free to open a PR with any suggestions! We'll be actively working on the library ourselves. If you need control to the repo, please contact me <a href="mailto:rex.raphael@outlook.com">Rex Raphael</a>. Please fork and send your PRs to the <a href="https://github.com/juicycleff/flutter-graphql/tree/v1.0.0">v.1.0.0</a> branch.

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind are welcome!

[version-badge]: https://img.shields.io/pub/v/flutter_graphql.svg?style=flat-square
[package]: https://pub.dartlang.org/packages/flutter_graphql/versions/1.0.0-alpha.12
[license-badge]: https://img.shields.io/github/license/juicycleff/flutter-graphql.svg?style=flat-square
[license]: https://github.com/juicycleff/flutter-graphql/blob/master/LICENSE
[prs-badge]: https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square
[prs]: http://makeapullrequest.com
[github-watch-badge]: https://img.shields.io/github/watchers/juicycleff/flutter-graphql.svg?style=social
[github-watch]: https://github.com/juicycleff/flutter-graphql/watchers
[github-star-badge]: https://img.shields.io/github/stars/juicycleff/flutter-graphql.svg?style=social
[github-star]: https://github.com/juicycleff/flutter-graphql/stargazers
