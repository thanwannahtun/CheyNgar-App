import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;

    return Center(
      // child: Lottie.asset(
      //   'assets/lottie/rocket-loading.json',
      //   height: width * 0.5,
      //   fit: BoxFit.contain,
      //   width: width * 0.5,
      // ),
      child: CircularProgressIndicator.adaptive(),
    );
  }
}

class LoaddingStack extends StatelessWidget {
  final Widget child;
  final bool loading;

  const LoaddingStack({super.key, required this.child, required this.loading});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading) Center(child: CircularProgressIndicator.adaptive()),
      ],
    );
  }
}

class LoadingStack extends StatelessWidget {
  final Widget child;
  final bool loading;
  final String? message;
  final Color? overlayColor;
  final int alpha;

  const LoadingStack({
    super.key,
    required this.child,
    required this.loading,
    this.message,
    this.overlayColor,
    this.alpha = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base UI
        child,

        // Loading Overlay
        if (loading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: loading,
              child: AnimatedOpacity(
                opacity: loading ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: (overlayColor ?? Colors.black).withAlpha(alpha),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        if (message != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            message!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
