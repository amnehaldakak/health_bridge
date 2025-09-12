import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class FileInfoCard extends StatelessWidget {
  const FileInfoCard({
    Key? key,
    required this.info,
  }) : super(key: key);

  /// info: خريطة تحتوي على keys: title, numOfFiles, svgSrc, color
  final Map<String, dynamic> info;

  @override
  Widget build(BuildContext context) {
    final Color color = info['color'] ?? Colors.blue;
    final String svgSrc = info['svgSrc'] ?? '';
    final String title = info['title'] ?? '';
    final int numOfFiles = info['numOfFiles'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(defaultPadding * 0.75),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: svgSrc.isNotEmpty
                    ? SvgPicture.asset(
                        svgSrc,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      )
                    : const SizedBox.shrink(),
              ),
              const Icon(Icons.more_vert, color: Colors.white54)
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "$numOfFiles",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      color.withOpacity(0.9), // نفس لون المربع لكن أغمق قليلاً
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
