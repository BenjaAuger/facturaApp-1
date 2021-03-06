import 'package:factura/pages/buttons.dart';
import 'package:factura/pages/pdf_page.dart';
import 'package:factura/providers/InfoProvider.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:intl/intl.dart';

class BoletaPage extends StatefulWidget {
  @override
  _BoletaPageState createState() => _BoletaPageState();
}

class _BoletaPageState extends State<BoletaPage> {
  InfoProvider infoPro = new InfoProvider();

  final _formKey = GlobalKey<FormState>();

  TextEditingController desCon = TextEditingController();

  String desc;
  int totNeto;
  int totIva;
  int totBruto;

  String pdfString;

  var userQuestion = '';
  var userAnswer = '';

  final List<String> buttons = [
    'C',
    'DEL',
    '',
    '/',
    '7',
    '8',
    '9',
    'x',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '',
    '=',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        //Fondo(plantilla) de la aplicación
        appBar: AppBar(
          //Barra superior
          title: Center(child: Text('Boleta')),
          backgroundColor: Colors.deepPurple,
          elevation: 4.0,
        ),
        body: Column(
          //Cuerpo de la app
          //Se crea una columna en el body
          children: [
            //EXPRESION Y RESULTADO
            Expanded(
              flex: 2,
              //Utilizamos todo el espacio del container
              child: Container(
                color: Colors.deepPurple[100],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        padding: EdgeInsets.all(1),
                        alignment: Alignment.centerLeft,
                        child:
                            Text(userQuestion, style: TextStyle(fontSize: 25))),
                    Container(
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.centerRight,
                      child: Text(
                        userAnswer,
                        style: TextStyle(fontSize: 35),
                      ),
                    ),
                  ],
                ),
              ), //Contenedor que se usara para los resultados.
            ),
            //BOTONES
            Expanded(
              flex: 3, //Se especifica que se ocupe 2/3 de la columna expandida.
              child: Container(
                color: Colors.deepPurple[100],
                child: Center(
                  child: GridView.builder(
                    itemCount: buttons.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, childAspectRatio: 1.9),
                    itemBuilder: (BuildContext context, int index) {
                      //Boton C = Clear
                      if (index == 0) {
                        return MyButton(
                          buttonTapped: () {
                            setState(() {
                              userQuestion = '';
                              userAnswer = '';
                            });
                          },
                          buttonText: buttons[index],
                          color: Colors.green,
                          textColor: Colors.white,
                          textsize: 30.0,
                        );
                      }
                      //Boton DEL = Delete
                      else if (index == 1) {
                        return MyButton(
                          buttonTapped: () {
                            setState(() {
                              // Desde la posicion 0 (primer valor) segun userQuestion.length (largo total) extraer 1.
                              userQuestion = userQuestion.substring(
                                  0, userQuestion.length - 1);
                              if (userQuestion == "") {
                                userQuestion = '';
                              }
                            });
                          },
                          buttonText: buttons[index],
                          color: Colors.red,
                          textColor: Colors.white,
                          textsize: 30.0,
                        );
                        // Boton = Resultado
                      } else if (index == buttons.length - 1) {
                        return MyButton(
                          buttonTapped: () {
                            setState(() {
                              //Referencia al metodo math_expressions.
                              equalPressed();
                              var f = NumberFormat('###,###');
                              int numerInt = double.parse(userAnswer).floor();
                              String numFor = f.format(numerInt);
                              userAnswer = numFor;
                              print(userAnswer);
                              userQuestion = userAnswer;
                            });
                          },
                          buttonText: buttons[index],
                          color: Colors.red,
                          textColor: Colors.white,
                          textsize: 30.0,
                        );
                        //Los demas botones
                      } else
                        return MyButton(
                          buttonTapped: () {
                            setState(() {
                              // userQuestion = userQuestion + buttons[index];
                              userQuestion += buttons[index];
                            });
                          },
                          buttonText: buttons[index],
                          color: isOperator(buttons[index])
                              ? Colors.deepPurple
                              : Colors.white,
                          textColor: isOperator(buttons[index])
                              ? Colors.white
                              : Colors.deepPurple,
                          textsize: 30.0,
                        );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(8),
                  color: Colors.deepPurple[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextFormField(
                        cursorColor: Colors.deepPurple,
                        style: TextStyle(color: Colors.deepPurple),
                        keyboardType: TextInputType.text,
                        controller: desCon,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          labelStyle: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                          labelText: 'Descripción',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Por favor ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      RaisedButton(
                          child: Text('Enviar'),
                          textColor: Colors.white,
                          color: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200.0)),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              double value =
                                  double.parse(userAnswer.replaceAll(',', '')) /
                                      1.19;
                              totNeto = value.round();
                              double value2 = totNeto * 0.19;
                              totIva = value2.floor();
                              totBruto = totNeto + totIva;
                              desc = desCon.text.toString();
                              await infoPro
                                  .postBoleta(desc, totNeto, totIva, totBruto)
                                  .then((value) => pdfString = value.pdf);

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PdfPage(
                                        pdfString: pdfString,
                                      )));
                              desCon.clear();
                              userQuestion = '';
                              userAnswer = '';
                            } else if (userAnswer == '') {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('Alerta'),
                                        content: Text(
                                            'Debe ingresar un monto para la boleta'),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Ok'))
                                        ],
                                      ));
                            }
                          }),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

  void equalPressed() {
    String finalQuestion = userQuestion;
    finalQuestion = finalQuestion.replaceAll('x', '*');
    finalQuestion = finalQuestion.replaceAll(',', '');
    Parser p = Parser();
    Expression exp = p.parse(finalQuestion);
    ContextModel cm = ContextModel();
    double eval = exp.evaluate(EvaluationType.REAL, cm);

    userAnswer = eval.toString();
  }
}
