// Template: adapt loading/error visuals and route ownership to the host app.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'post_bloc.dart';

class PostsList extends StatefulWidget {
  const PostsList({super.key});

  @override
  State<PostsList> createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostBloc>().add(const PostFetched());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * .8) {
      context.read<PostBloc>().add(const PostFetched());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PostBloc, PostState>(
        builder: (context, state) => ListView.builder(
          controller: _scrollController,
          itemCount: state.posts.length + (state.loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.posts.length) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ));
            }
            final post = state.posts[index];
            return ListTile(key: ValueKey(post.id), title: Text(post.title));
          },
        ),
      );
}
