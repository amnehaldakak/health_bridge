import 'package:flutter/material.dart';

class AddRecords extends StatefulWidget {
  const AddRecords({Key? key}) : super(key: key);

  @override
  State<AddRecords> createState() => _AddRecordsState();
}

class _AddRecordsState extends State<AddRecords> {
  int currentStep = 0;
  final _storyKey = GlobalKey<FormState>();
  final _examKey = GlobalKey<FormState>();
  final _diagnosisKey = GlobalKey<FormState>();
  final List<String> smoking = ['نعم', 'لا'];
  String? selected;

  final controllers = <String, TextEditingController>{
    "chiefComplaint": TextEditingController(),
    "symptoms": TextEditingController(),
    "pastMedical": TextEditingController(),
    "pastSurgical": TextEditingController(),
    "medications": TextEditingController(),
    "allergies": TextEditingController(),
    "smoking": TextEditingController(),
    "signs": TextEditingController(),
    "vitals": TextEditingController(),
    "examResult": TextEditingController(),
    "diagnosis": TextEditingController(),
    "medicationPlan": TextEditingController(),
  };

  @override
  void dispose() {
    controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الاستمارة الطبية'),
          centerTitle: true,
        ),
        body: Stepper(
          type: StepperType.vertical,
          currentStep: currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) {
            if (step > 2 && !_diagnosisValidated()) return;
            setState(() => currentStep = step);
          },
          controlsBuilder: (context, details) {
            final isLast = currentStep == _steps(context).length - 1;
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'التالي' : 'التالي'),
                ),
                const SizedBox(width: 12),
                if (currentStep > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('السابق'),
                  ),
              ],
            );
          },
          steps: _steps(context),
        ),
      ),
    );
  }

  List<Step> _steps(BuildContext context) {
    return [
      Step(
        title: const Text('القصة السريرية'),
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _storyKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              field("الشكاية الرئيسية", controllers["chiefComplaint"]!,
                  maxLines: 2),
              field("الأعراض", controllers["symptoms"]!, maxLines: 2),
              optionalField("السوابق المرضية", controllers["pastMedical"]!,
                  maxLines: 2),
              optionalField("السوابق الجراحية", controllers["pastSurgical"]!,
                  maxLines: 2),
              optionalField("السوابق الدوائية", controllers["medications"]!,
                  maxLines: 2),
              optionalField("التحسس", controllers["allergies"]!, maxLines: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: DropdownButtonFormField<String>(
                  value: selected,
                  decoration: InputDecoration(
                    labelText: 'التدخين',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  items: smoking.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selected = value;
                      controllers["smoking"]!.text = value!;
                    });
                  },
                ),
              )
            ],
          ),
        ),
      ),
      Step(
        title: const Text('الفحص السريري'),
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _examKey,
          child: Column(
            children: [
              field("العلامات", controllers["signs"]!, maxLines: 2),
              field("العلامات الحيوية", controllers["vitals"]!,
                  hint: "ضغط، حرارة، نبض...", maxLines: 2),
              field("نتيجة الفحص السريري", controllers["examResult"]!,
                  maxLines: 3),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('التشخيص'),
        isActive: currentStep >= 2,
        state: StepState.indexed,
        content: Form(
          key: _diagnosisKey,
          child: Column(
            children: [
              field("التشخيص", controllers["diagnosis"]!, maxLines: 2),
            ],
          ),
        ),
      ),
    ];
  }

  void _onStepContinue() {
    final formKeys = [_storyKey, _examKey, _diagnosisKey];
    final isLast = currentStep == _steps(context).length - 1;

    if (formKeys[currentStep] != null &&
        formKeys[currentStep]!.currentState?.validate() != true) {
      return;
    }

    if (isLast && _diagnosisValidated()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreatmentPage(
            initialPlan: controllers["medicationPlan"]!.text,
            onSaved: (value) {
              controllers["medicationPlan"]!.text = value;
              _submit();
            },
          ),
        ),
      );
    } else {
      setState(() => currentStep += 1);
    }
  }

  void _onStepCancel() {
    if (currentStep == 0) return;
    setState(() => currentStep -= 1);
  }

  bool _diagnosisValidated() {
    return controllers["diagnosis"]!.text.trim().isNotEmpty;
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال البيانات بنجاح')),
    );
  }

  Widget field(String label, TextEditingController controller,
      {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: const [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'يرجى تعبئة هذا الحقل'
            : null,
      ),
    );
  }

  Widget optionalField(String label, TextEditingController controller,
      {int maxLines = 1, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class TreatmentPage extends StatefulWidget {
  final String initialPlan;
  final void Function(String value) onSaved;

  const TreatmentPage({
    Key? key,
    required this.initialPlan,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPlan);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الخطة العلاجية / الأدوية'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'الأدوية الموصوفة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onSaved(_controller.text);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('حفظ'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
