import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';

/// 병원 등록을 위한 임시 드래프트 모델 (백엔드 연동 전 단계)
class ClinicDraft {
  final String nameKo;
  final String nameEn;
  final String businessNumber;
  final String phone;
  final String email;
  final String website;
  final String country;
  final String city;
  final String district;
  final String addressLine;
  final double? lat;
  final double? lng;
  final Map<String, Map<String, String?>> businessHours; // { Mon: {open:'09:00', close:'18:00'}, ... }
  final List<String> procedures; // 수술/시술 카테고리 태그
  final List<String> languages;  // 상담 가능 언어
  final bool boardCertified;
  final bool anesthesiologistOnSite;
  final bool recoveryRoom;
  final bool cctv;
  final bool parking;
  final bool foreignerSupport;
  final String description;
  final List<String> imageUrls; // 대표/갤러리 이미지 URL
  final Map<String, String> social; // {instagram: ..., youtube: ..., tiktok: ...}

  ClinicDraft({
    required this.nameKo,
    required this.nameEn,
    required this.businessNumber,
    required this.phone,
    required this.email,
    required this.website,
    required this.country,
    required this.city,
    required this.district,
    required this.addressLine,
    required this.lat,
    required this.lng,
    required this.businessHours,
    required this.procedures,
    required this.languages,
    required this.boardCertified,
    required this.anesthesiologistOnSite,
    required this.recoveryRoom,
    required this.cctv,
    required this.parking,
    required this.foreignerSupport,
    required this.description,
    required this.imageUrls,
    required this.social,
  });

  Map<String, dynamic> toJson() => {
        'nameKo': nameKo,
        'nameEn': nameEn,
        'businessNumber': businessNumber,
        'phone': phone,
        'email': email,
        'website': website,
        'country': country,
        'city': city,
        'district': district,
        'addressLine': addressLine,
        'lat': lat,
        'lng': lng,
        'businessHours': businessHours,
        'procedures': procedures,
        'languages': languages,
        'flags': {
          'boardCertified': boardCertified,
          'anesthesiologistOnSite': anesthesiologistOnSite,
          'recoveryRoom': recoveryRoom,
          'cctv': cctv,
          'parking': parking,
          'foreignerSupport': foreignerSupport,
        },
        'description': description,
        'imageUrls': imageUrls,
        'social': social,
      };
}

class ClinicFormScreen extends StatefulWidget {
  const ClinicFormScreen({super.key});

  @override
  State<ClinicFormScreen> createState() => _ClinicFormScreenState();
}

class _ClinicFormScreenState extends State<ClinicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  // 기본정보
  final _nameKo = TextEditingController();
  final _nameEn = TextEditingController();
  final _bizNum = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  // 주소/위치
  final _country = TextEditingController(text: 'South Korea');
  final _city = TextEditingController(text: 'Seoul');
  final _district = TextEditingController(text: 'Gangnam-gu');
  final _address = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  // 설명/이미지/소셜
  final _description = TextEditingController();
  final _imageUrls = TextEditingController(); // 콤마(,)로 여러 개
  final _instagram = TextEditingController();
  final _youtube = TextEditingController();
  final _tiktok = TextEditingController();

  // 시술/언어 선택
  final List<String> _procedurePool = const [
    'Eye Surgery',
    'Rhinoplasty',
    'Filler',
    'Botox',
    'Facial Contouring',
    'Breast Surgery',
    'Thread Lift',
    'Skin Treatment',
  ];
  final List<String> _languagePool = const [
    'Korean',
    'English',
    'Japanese',
    'Chinese',
    'Thai',
    'Vietnamese',
  ];
  final Set<String> _selectedProcedures = {};
  final Set<String> _selectedLanguages = {'Korean', 'English'};

  // 인증/편의
  bool _boardCertified = true;
  bool _anesthesiologistOnSite = true;
  bool _recoveryRoom = true;
  bool _cctv = true;
  bool _parking = true;
  bool _foreignerSupport = true;

  // 영업시간
  final List<String> _days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Map<String, TimeOfDay?> _open = {};
  final Map<String, TimeOfDay?> _close = {};
  bool _hoursSameOnWeekdays = true;

  @override
  void initState() {
    super.initState();
    for (final d in _days) {
      _open[d] = null;
      _close[d] = null;
    }
  }

  @override
  void dispose() {
    _nameKo.dispose();
    _nameEn.dispose();
    _bizNum.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _country.dispose();
    _city.dispose();
    _district.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    _description.dispose();
    _imageUrls.dispose();
    _instagram.dispose();
    _youtube.dispose();
    _tiktok.dispose();
    super.dispose();
  }

  Future<void> _fillCurrentLocation() async {
    final service = LocationService();
    final pos = await service.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _lat.text = pos.latitude.toStringAsFixed(6);
        _lng.text = pos.longitude.toStringAsFixed(6);
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치를 가져올 수 없습니다. 위치 권한을 확인하세요.')),
      );
    }
  }

  Future<void> _pickTime(String day, bool isOpen) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isOpen) {
        _open[day] = picked;
        if (_hoursSameOnWeekdays && ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].contains(day)) {
          for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
            _open[d] = picked;
          }
        }
      } else {
        _close[day] = picked;
        if (_hoursSameOnWeekdays && ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].contains(day)) {
          for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
            _close[d] = picked;
          }
        }
      }
    });
  }

  String _fmt(TimeOfDay? t) => t == null ? '--:--' : t.format(context);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    double? lat = double.tryParse(_lat.text.trim());
    double? lng = double.tryParse(_lng.text.trim());
    final hours = <String, Map<String, String?>>{};
    for (final d in _days) {
      hours[d] = {
        'open': _open[d] == null ? null : _open[d]!.format(context),
        'close': _close[d] == null ? null : _close[d]!.format(context),
      };
    }
    final draft = ClinicDraft(
      nameKo: _nameKo.text.trim(),
      nameEn: _nameEn.text.trim(),
      businessNumber: _bizNum.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      website: _website.text.trim(),
      country: _country.text.trim(),
      city: _city.text.trim(),
      district: _district.text.trim(),
      addressLine: _address.text.trim(),
      lat: lat,
      lng: lng,
      businessHours: hours,
      procedures: _selectedProcedures.toList(),
      languages: _selectedLanguages.toList(),
      boardCertified: _boardCertified,
      anesthesiologistOnSite: _anesthesiologistOnSite,
      recoveryRoom: _recoveryRoom,
      cctv: _cctv,
      parking: _parking,
      foreignerSupport: _foreignerSupport,
      description: _description.text.trim(),
      imageUrls: _imageUrls.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      social: {
        'instagram': _instagram.text.trim(),
        'youtube': _youtube.text.trim(),
        'tiktok': _tiktok.text.trim(),
      },
    );
    Navigator.of(context).pop(draft.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Clinic'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Basic Information'),
                _LabeledField(
                  label: 'Clinic Name (KO)*',
                  controller: _nameKo,
                  validator: (v) => (v == null || v.trim().isEmpty) ? '필수 입력' : null,
                ),
                _LabeledField(label: 'Clinic Name (EN)', controller: _nameEn),
                _LabeledField(label: 'Business Reg. Number', controller: _bizNum),
                _LabeledField(label: 'Phone', controller: _phone),
                _LabeledField(
                  label: 'Email',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
                    return ok ? null : '이메일 형식이 올바르지 않습니다';
                  },
                ),
                _LabeledField(label: 'Website', controller: _website),
                const SizedBox(height: 12),
                const _SectionTitle('Address & Location'),
                Row(
                  children: [
                    Expanded(child: _LabeledField(label: 'Country', controller: _country)),
                    const SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'City', controller: _city)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _LabeledField(label: 'District', controller: _district)),
                    const SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'Address Line', controller: _address)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'Latitude',
                        controller: _lat,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: 'Longitude',
                        controller: _lng,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _fillCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionTitle('Business Hours'),
                Row(
                  children: [
                    Checkbox(
                      value: _hoursSameOnWeekdays,
                      onChanged: (v) => setState(() => _hoursSameOnWeekdays = v ?? true),
                    ),
                    const Text('Mon–Fri 동일 시간 적용'),
                  ],
                ),
                const SizedBox(height: 6),
                ..._days.map((d) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 48, child: Text(d, style: const TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _pickTime(d, true),
                          child: Text('Open: ${_fmt(_open[d])}'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => _pickTime(d, false),
                          child: Text('Close: ${_fmt(_close[d])}'),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const _SectionTitle('Procedures'),
                _ChipsMultiSelect(
                  options: _procedurePool,
                  selected: _selectedProcedures,
                  onChanged: (s) => setState(() => _selectedProcedures
                    ..clear()
                    ..addAll(s)),
                ),
                const SizedBox(height: 12),
                const _SectionTitle('Languages'),
                _ChipsMultiSelect(
                  options: _languagePool,
                  selected: _selectedLanguages,
                  onChanged: (s) => setState(() => _selectedLanguages
                    ..clear()
                    ..addAll(s)),
                ),
                const SizedBox(height: 12),
                const _SectionTitle('Certifications & Amenities'),
                _AmenitySwitch(title: 'Board-certified', value: _boardCertified, onChanged: (v) => setState(() => _boardCertified = v)),
                _AmenitySwitch(title: 'Anesthesiologist On-site', value: _anesthesiologistOnSite, onChanged: (v) => setState(() => _anesthesiologistOnSite = v)),
                _AmenitySwitch(title: 'Recovery Room', value: _recoveryRoom, onChanged: (v) => setState(() => _recoveryRoom = v)),
                _AmenitySwitch(title: 'CCTV', value: _cctv, onChanged: (v) => setState(() => _cctv = v)),
                _AmenitySwitch(title: 'Parking', value: _parking, onChanged: (v) => setState(() => _parking = v)),
                _AmenitySwitch(title: 'Foreigner Support', value: _foreignerSupport, onChanged: (v) => setState(() => _foreignerSupport = v)),
                const SizedBox(height: 12),
                const _SectionTitle('Description'),
                _LabeledField(
                  label: 'Clinic Description',
                  controller: _description,
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                const _SectionTitle('Images & Social'),
                _LabeledField(
                  label: 'Image URLs (comma separated)',
                  controller: _imageUrls,
                  hintText: 'https://.../hero.jpg, https://.../room.jpg',
                ),
                Row(
                  children: [
                    Expanded(child: _LabeledField(label: 'Instagram', controller: _instagram)),
                    const SizedBox(width: 12),
                    Expanded(child: _LabeledField(label: 'YouTube', controller: _youtube)),
                  ],
                ),
                _LabeledField(label: 'TikTok', controller: _tiktok),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check),
                        label: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  const _LabeledField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipsMultiSelect extends StatefulWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const _ChipsMultiSelect({required this.options, required this.selected, required this.onChanged});
  @override
  State<_ChipsMultiSelect> createState() => _ChipsMultiSelectState();
}

class _ChipsMultiSelectState extends State<_ChipsMultiSelect> {
  late Set<String> _sel;
  @override
  void initState() {
    super.initState();
    _sel = {...widget.selected};
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((o) {
        final picked = _sel.contains(o);
        return ChoiceChip(
          label: Text(o),
          selected: picked,
          onSelected: (v) {
            setState(() {
              if (v) {
                _sel.add(o);
              } else {
                _sel.remove(o);
              }
              widget.onChanged(_sel);
            });
          },
        );
      }).toList(),
    );
  }
}

class _AmenitySwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AmenitySwitch({required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
