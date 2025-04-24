import 'package:byhands_application/theme.dart';
import 'package:flutter/material.dart';
import 'package:byhands_application/menus/side_menu.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:easy_localization/easy_localization.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  List<Map<String, dynamic>> FAQsList = [];
  final SupabaseClient supabase = Supabase.instance.client;
  int userID = 0;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchInformation();
  }

  Future<void> fetchInformation() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;
    if (email == null) {
      setState(() => userID = 0);
      return;
    }

    final response =
        await supabase.from('User').select().eq('Email', email).maybeSingle();
    setState(() {
      userID = response?['UserID'] ?? 0;
    });
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('FAQ').select();
      setState(() {
        FAQsList = (response as List<dynamic>?)
                ?.map((e) => {
                      'Question': e['Question'] ?? 'Unknown',
                      'Answer': e['Answer'] ?? 'No answer available'
                    })
                .toList() ??
            [];
      });
    } catch (error) {
      print('Error fetching FAQ: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('help.title'.tr(), style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, '/Home'),
            icon: const Icon(Icons.home),
          )
        ],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      drawer: CommonDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('help.helpSupport'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('help.appOverview'.tr(), style: Theme.of(context).textTheme.titleLarge),
            onTap: () => Navigator.pushNamed(context, '/AppOverView'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text('help.howToUse'.tr(), style: Theme.of(context).textTheme.titleLarge),
            onTap: () => Navigator.pushNamed(context, '/HowTo'),
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: Text('help.contactSupport'.tr(), style: Theme.of(context).textTheme.titleLarge),
            onTap: () => _contactUs(context),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: Text('help.sendFeedback'.tr(), style: Theme.of(context).textTheme.titleLarge),
            onTap: () => _NewFeedback(context),
          ),
          ListTile(
            leading: const Icon(Icons.format_quote),
            title: Text('help.faqs'.tr(), style: Theme.of(context).textTheme.titleLarge),
            onTap: () => _NewFAQs(context),
          ),
          const SizedBox(height: 20),
          FAQsList.isEmpty
              ? Center(child: Text('help.noFAQFound'.tr()))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: FAQsList.length,
                  itemBuilder: (context, index) {
                    final category = FAQsList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        decoration: customContainerDecoration(context),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(category['Question'] ?? '',
                              style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text(category['Answer'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _NewFAQs(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final QuestionController = TextEditingController();

    Future<void> insertFAQ() async {
      try {
        await supabase.from('FAQ').insert({'Question': QuestionController.text});
      } catch (e) {
        print("Error inserting FAQ: $e");
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('help.addQuestion'.tr()),
        content: Form(
          key: formfield,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                QuestionController,
                'help.askQuestion'.tr(),
                'help.enterQuestion'.tr(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('help.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (formfield.currentState!.validate()) {
                insertFAQ();
                Navigator.pop(context);
              }
            },
            child: Text('help.submit'.tr()),
          ),
        ],
      ),
    );
  }

  void _contactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('help.contactSupport'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'help.phone'.tr()} : +973 17000000'),
            Text('${'help.email'.tr()} : byhandsapplication@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('help.ok'.tr()),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void _NewFeedback(BuildContext context) {
    final formfield = GlobalKey<FormState>();
    final FeedbackController = TextEditingController();
    double Rating = 0;

    Future<void> insertFeedback() async {
      try {
        await supabase.from('Feedback').insert({
          'user_id': userID,
          'feedback_content': FeedbackController.text,
          'rate': Rating,
        });
      } catch (e) {
        print("Error inserting feedback: $e");
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('help.sendFeedback'.tr()),
        content: Form(
          key: formfield,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                FeedbackController,
                'help.yourFeedback'.tr(),
                'help.enterFeedback'.tr(),
              ),
              const SizedBox(height: 15),
              RatingBar.builder(
                initialRating: 1,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  Rating = rating;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('help.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (formfield.currentState!.validate()) {
                insertFeedback();
                Navigator.pop(context);
              }
            },
            child: Text('help.submit'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, String validatorText) {
    return TextFormField(
      controller: controller,
      decoration: textInputdecoration(context, labelText),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
    );
  }
}
