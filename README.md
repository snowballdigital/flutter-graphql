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
    - [Graphql Link and Headers] (#graphql-link-and-headers)
    - [Offline Cache](#offline-cache)
      - [Normalization](#normalization)
    - [Queries](#queries)
    - [Mutations](#mutations)
    - [Subscriptions (Experimental)](#subscriptions-experimental)
    - [Graphql Consumer](#graphql-consumer)
    - [Fragments](#fragments)
    - [Usage outside a widget](#outside-a-widget)
  - [Roadmap](#roadmap)
  - [Contributing](#contributing)
  - [New Contributors](#new-contributors)
  - [Founding Contributors](#founding-contributors)

## About this project

GraphQL brings many benefits, both to the client: devices will need less requests, and therefore reduce data useage. And to the programer: requests are arguable, they have the same structure as the request.

This project combines the benefits of GraphQL with the benefits of `Streams` in Dart to deliver a high performace client.

The project took inspriation from the [Apollo GraphQL client](https://github.com/apollographql/apollo-client), great work guys!

**Note: Still in Beta**
**Docs is coming soon**
**Support for all Apollo Graphql component supported props is coming soon**

## Installation

First depend on the library by adding this to your packages `pubspec.yaml`:

```yaml
dependencies:
  flutter_graphql: ^1.0.0-rc.1
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

### Graphql Link and Headers
You can setup authentication headers and other custom links just like you do with Apollo Graphql

```dart
  import 'dart:async';

  import 'package:flutter/material.dart';
  import 'package:flutter_graphql/flutter_graphql.dart';
  import 'package:flutter_graphql/src/link/operation.dart';
  import 'package:flutter_graphql/src/link/fetch_result.dart';

  class AuthLink extends Link {
    AuthLink()
        : super(
      request: (Operation operation, [NextLink forward]) {
        StreamController<FetchResult> controller;

        Future<void> onListen() async {
          try {
            var token = await AuthUtil.getToken();
            operation.setContext(<String, Map<String, String>>{
              'headers': <String, String>{'Authorization': '''bearer $token'''}
            });
          } catch (error) {
            controller.addError(error);
          }

          await controller.addStream(forward(operation));
          await controller.close();
        }

        controller = StreamController<FetchResult>(onListen: onListen);

        return controller.stream;
      },
    );
  }

  var cache = InMemoryCache();

  var authLink = AuthLink()
      .concat(HttpLink(uri: 'http://yourgraphqlserver.com/graphql'));
      
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: cache,
      link: authLink,
    ),
  );

  final ValueNotifier<GraphQLClient> anotherClient = ValueNotifier(
    GraphQLClient(
      cache: cache,
      link: authLink,
    ),
  );
    
```
However note that **`flutter-graphql` does not inject __typename into operations** the way apollo does, so if you aren't careful to request them in your query, this normalization scheme is not possible.

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

To create a query, you just need to define a String variable like the one below. With full support of fragments

```dart
const GET_ALL_PEOPLE = '''
  query getPeople{
    readAll{
      name
      age
      sex
    }
  }
''';
```

In your widget:

```dart
...

Query(
  options: QueryOptions(
    document: GET_ALL_PEOPLE, // this is the query string you just created
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
    List people = result.data['getPeople'];

    return ListView.builder(
      itemCount: people.length,
      itemBuilder: (context, index) {
        final repository = people[index];

        return Text(people['name']);
    });
  },
);

...
```

Other examples with query argments and passing in a custom graphql client

```dart
const READ_BY_ID = '''
  query readById(\$id: String!){
    readById(ID: \$id){
      name
      age
      sex
    }
  }
  
  
final ValueNotifier<GraphQLClient> userClient = ValueNotifier(
  GraphQLClient(
    cache: cache,
    link: authLinkProfile,
  ),
);

''';
```

In your widget:

```dart
...

Query(
  options: QueryOptions(
    document: READ_BY_ID, // this is the query string you just created
    pollInterval: 10,
    client: userClient.value
  ),
  builder: (QueryResult result) {
    if (result.errors != null) {
      return Text(result.errors.toString());
    }

    if (result.loading) {
      return Text('Loading');
    }

    // it can be either Map or List
    List person = result.data['getPeople'];

    return Text(person['name']);
  },
);

...
```

### Mutations

Again first create a mutation string:

```dart
const LIKE_BLOG = '''
  mutation likeBlog(\$id: Int!) {
    likeBlog(id: \$id){
      name
      author {
        name
        displayImage
      }
  }
''';
```

The syntax for mutations is fairly similar to that of a query. The only diffence is that the first argument of the builder function is a mutation function. Just call it to trigger the mutations (Yeah we deliberately stole this from react-apollo.)

```dart
...

Mutation(
  options: MutationOptions(
    document: LIKE_BLOG, // this is the mutation string you just created
  ),
  builder: (
    RunMutation runMutation,
    QueryResult result,
  ) {
    return FloatingActionButton(
      onPressed: () => runMutation({
        'id': <BLOG_ID>,
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

You can always access the client direcly from the `GraphQLProvider` but to make it even easier you can also use the `GraphQLConsumer` widget. You can also pass in a another client to the consumer

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

A different client:

```dart
  ...

  return GraphQLConsumer(
    client: userClient,
    builder: (GraphQLClient client) {
      // do something with the client

      return Container(
        child: Text('Hello world'),
      );
    },
  );

  ...
```

### Fragments

There is support for fragments and it's basically how you use it in Apollo React. For example define your fragment as a dart String.

```dart
  ...
const UserFragment = '''
  fragment UserFragmentFull on Profile {
    address {
      city
      country
      postalCode
      street
    }
    birthdate
    email
    firstname
    id
    lastname]
  }
  ''';

  ...
```

Now you can use it in your Graphql Query or Mutation String like below
```dart
  ...

  const CURRENT_USER = '''
    query read{
      read {
      ...UserFragmentFull
      }
    }
    $UserFragment
  ''';

  ...
```

or

```dart
  ...

  const GET_BLOGS = '''
    query getBlogs{
      getBlog {
        title
        description
        tags
        
        author {
          ...UserFragmentFull
        }
    }
    $UserFragment
  ''';

  ...
```

### Outside a Widget

Similar to withApollo or graphql HoC that passes the client to the component in react, you can call a graphql query from any part of your code base even in a your service class or in your Scoped MOdel or Bloc class. Example

```dart
  ...

  class AuthUtil{
    static Future<String> getToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.getString('token');
    }

    static Future setToken(value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString('token', value);
    }

    static removeToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove('token');
    }

    static clear() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    }
    
    static Future<bool> logIn(String username, String password) async {
      var token;

      QueryOptions queryOptions = QueryOptions(
          document: LOGIN,
          variables: {
            'username': username,
            'password': password
          }
      );

      if (result != null) {
        this.setToken(result);
        return clientProfile.value.query(queryOptions).then((result) async {

          if(result.data != null) {
            token = result.data['login']['token];
            notifyListeners();
            return token;
          } else {
            return throw Error;
          }

        }).catchError((error) {
            return throw Error;
        });
      } else
        return false;
    }
  }

  ...
```

In a scoped model:

```dart
  ...
class AppModel extends Model {

  String token = '';
  var currentUser = new Map <String, dynamic>();

  static AppModel of(BuildContext context) =>
      ScopedModel.of<AppModel>(context);

  void setToken(String value) {
    token = value;
    AuthUtil.setAppURI(value);
    notifyListeners();
  }


  String getToken() {
    if (token != null) return token;
    else AuthUtil.getToken();
  }

  getCurrentUser() {
    return currentUser;
  }

  Future<bool> isLoggedIn() async {

    var result = await AuthUtil.getToken();
    print(result);

    QueryOptions queryOptions = QueryOptions(
        document: CURRENT_USER
    );

    if (result != null) {
      print(result);
      this.setToken(result);
      return clientProfile.value.query(queryOptions).then((result) async {

        if(result.data != null) {
          currentUser = result.data['read'];
          notifyListeners();
          return true;
        } else {
          return false;
        }

      }).catchError((error) {
        print('''Error => $error''');
        return false;
      });
    } else
      return false;
  }
}
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
