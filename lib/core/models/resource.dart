class ResourceItem {
  final String id;
  final String title;
  final String course;
  final String type;
  final bool availableOffline;
  final String? description;
  final String? url;
  final int? pages;
  final String? year;
  final double? sizeMb;

  const ResourceItem({
    required this.id,
    required this.title,
    required this.course,
    required this.type,
    required this.availableOffline,
    this.description,
    this.url,
    this.pages,
    this.year,
    this.sizeMb,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    final sizeRaw = json['size_mb'] ?? json['sizeMb'] ?? json['size'];
    final pagesRaw = json['pages'] ?? json['page_count'];
    return ResourceItem(
      id: json['id'].toString(),
      title: json['title'].toString(),
      course: (json['course'] ?? json['course_code'] ?? '').toString(),
      type: (json['type'] ?? json['format'] ?? '').toString(),
      availableOffline: json['availableOffline'] == true || json['available_offline'] == true,
      description: json['description']?.toString(),
      url: json['url']?.toString() ?? json['file_url']?.toString(),
      pages: pagesRaw == null ? null : int.tryParse(pagesRaw.toString()),
      year: json['year']?.toString(),
      sizeMb: sizeRaw == null ? null : double.tryParse(sizeRaw.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'course': course,
        'type': type,
        'availableOffline': availableOffline,
        'description': description,
        'url': url,
        'pages': pages,
        'year': year,
        'size_mb': sizeMb,
      };
}
