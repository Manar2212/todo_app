import 'package:buildcondition/buildcondition.dart';
import 'package:flutter/material.dart';
import '../cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpeerCase = true,
  double radius = 30.0,
  @required Function()? function,
  @required String text = '',
}) =>
    Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: background,
      ),
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpeerCase ? text.toUpperCase() : text,
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
    );

Widget defaultTextFormField({
  @required TextEditingController? controller,
  @required TextInputType? inputType,
  @required String? text,
  @required IconData? prefix,
  void Function(String)? onSubmit,
  void Function(String)? onChange,
  void Function()? ontap,
  @required String? Function(String?)? validate,
  bool isobscure = false,
  IconData? suffix,
  Function()? suffixPressed,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
          labelText: text,
          prefixIcon: Icon(prefix),
          suffixIcon: IconButton(onPressed: suffixPressed, icon: Icon(suffix)),
          border: OutlineInputBorder()),
      onFieldSubmitted: onSubmit,
      onChanged: onChange,
      validator: validate,
      obscureText: isobscure ? true : isobscure,
      onTap: ontap,
    );

Widget buildTaskItem(Map model, BuildContext context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: (Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(' ${model['time']} '),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .UpdateDatabase(status: 'done', id: model['id']);
                },
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )),
            IconButton(
                onPressed: () {
                  AppCubit.get(context)
                      .UpdateDatabase(status: 'archived', id: model['id']);
                },
                icon: Icon(
                  Icons.archive,
                  color: Colors.black45,
                ))
          ],
        )),
      ),
      onDismissed: ((direction) {
        AppCubit.get(context).DeleteDatabase(id: model['id']);
      }),
    );

Widget BuildTaskCondition({
  @required List<Map>? tasks,
}) {
  return BuildCondition(
    condition: tasks!.length > 0,
    builder: (context) {
      return ListView.separated(
          itemBuilder: ((context, index) =>
              buildTaskItem(tasks[index], context)),
          separatorBuilder: ((context, index) =>
              Divider(color: Colors.grey, height: 10)),
          itemCount: tasks.length);
    },
    fallback: (context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100,
              color: Colors.grey,
            ),
            Text(
              'No Tasks Yet, Please Add Some Tasks',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      );
    },
  );
}

void navigateTo(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
