class Tag {
  final String id;
  final String name;
  final int colorValue;

  const Tag({
    required this.id,
    required this.name,
    this.colorValue = 0x00000000,
  });

  Tag copyWith({String? name, int? colorValue}) {
    return Tag(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
      };

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        colorValue: json['colorValue'] as int? ?? 0x00000000,
      );
}
