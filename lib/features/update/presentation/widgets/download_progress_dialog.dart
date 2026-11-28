import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog showing live APK download progress driven by [UpdateBloc].
class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Screen size adaptive fields
    final screenSize = MediaQuery.sizeOf(context);
    final baseSide = screenSize.shortestSide;
    final horizontalPadding = (baseSide * 0.06).clamp(18.0, 36.0);
    final verticalPadding = (baseSide * 0.06).clamp(18.0, 36.0);
    final spacing = (baseSide * 0.055).clamp(16.0, 30.0);
    final titleFontSize = (baseSide * 0.055).clamp(18.0, 28.0);
    final indicatorSize = (baseSide * 0.24).clamp(84.0, 148.0);
    final strokeWidth = (indicatorSize * 0.13).clamp(10.0, 18.0);
    final percentFontSize = (indicatorSize * 0.21).clamp(16.0, 29.0);
    final maxDialogWidth = (baseSide * 0.78).clamp(260.0, 440.0);
    final minDialogWidth = (baseSide * 0.65).clamp(220.0, 360.0);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenSize.width * 0.08).clamp(16.0, 48.0),
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minDialogWidth,
          maxWidth: maxDialogWidth,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Download in corso',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
              SizedBox(height: spacing),
              BlocBuilder<UpdateBloc, UpdateState>(
                builder: (context, state) {
                  final progress = state is UpdateDownloadInProgress
                      ? state.progress.clamp(0.0, 1.0)
                      : 1.0;
                  return Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      SizedBox(
                        height: indicatorSize,
                        width: indicatorSize,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: colorScheme.primary,
                          backgroundColor: colorScheme.tertiary,
                          strokeWidth: strokeWidth,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      SizedBox(
                        width: indicatorSize - strokeWidth * 2 - 8,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: percentFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
