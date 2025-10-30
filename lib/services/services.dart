import 'package:flutter_dotenv/flutter_dotenv.dart';
//VERIFICA SI LA VARIBLE DE ENTORNO TIENE VALOR TRUE O FALSE 
//PARA SABER CON QUE VARIABLE INGRESARA
bool stateApp() => dotenv.env['STATE_PROD'] == 'true';
//SI PREGUNTARA DEL BACKEND DE PRODUCCION O DE PRUEBAS
String? hostSTI = stateApp() ? dotenv.env['HOST_STI_PROD'] : dotenv.env['HOST_STI_DEV'];
String? hostGATEWAY = stateApp()
    ? dotenv.env['HOST_GATEWAY_PROD']
    : dotenv.env['HOST_GATEWAY_DEV'];
//
String? auth = dotenv.env['auth'];
String? reazonAffiliate = dotenv.env['reazonAffiliate'];
String? reazonMovil = dotenv.env['reazonMovil'];
//VERIFICAR LA VERSION DE LA APLICACION
String serviceVersion() => '$hostGATEWAY/$reazonMovil/version';
//SOLICITUD DEL SMS
String loginAppMobile() => '$hostGATEWAY/$auth/loginAppMobile';
//VERIFICACION DEL PIN ENVIADO
String verifyPin() => '$hostGATEWAY/$auth/verifyPin';
//CERRAR SESION DE FORMA VOLUNTARIA
String serviceAuthSession() => '$hostGATEWAY/$auth/logoutAppMobile';
//SE ENVIA EL CARNET CORRESPONDIENTE A LA AUTENTICACION
String sendIdentityCard() => '$hostGATEWAY/$reazonMovil/ecoComSaveIdentity';
//CONTACTOS
String serviceGetContacts() => '$hostGATEWAY/$reazonMovil/globalCities';
//POLITICAS Y PRIVACIDAD
String serviceGetPrivacyPolicy() => 'https://www.muserpol.gob.bo/terminos-y-condiciones';
//CARGAR COMPLEMENTO ECONOMICO 
String serviceGetEconomicComplements(int page, bool current) => '$hostGATEWAY/$reazonMovil/ecoComEconomicComplements/?page=$page&current=$current';
//CARGAR OBSERVACIONES PARA COMPLEMENTO ECONOMICO
String serviceGetObservation(int affiliateId) => '$hostGATEWAY/$reazonMovil/ecoComAffiliateObservations/$affiliateId';
//CARGAR SI PUEDE REALIZAR EL TRAMITE
String serviceGetProcessingPermit(int affiliateId) => '$hostGATEWAY/$reazonMovil/ecoComLivenessShow/$affiliateId';
//VERIFICA SI YA SE TIENE EL CARNET DEL BENEFICIARIO
String serviceGetMessageFaceType(String type) => '$hostGATEWAY/$reazonMovil/message/$type';
//MENSAJE CORRESPONDIENTE A LAS ACCIONES PARA EL ENROLAMIENTO COMPLETO O SOLO CONTROL DE VIVENCIA
String serviceProcessEnrolled() => '$hostGATEWAY/$reazonMovil/ecoComLiveness';
//SE ENVIA LAS FOTOGRAFIAS DEL ENROLAMIENTO O CONTROL DE VIVENCIA
String serviceProcessEnrolledPost() => '$hostGATEWAY/$reazonMovil/ecoComLivenessStore';
//SE ENVIA LOS DATOS Y FOTOGRAFIAS DEL CARNET
String serviceSendImagesProcedure() => '$hostGATEWAY/$reazonMovil/ecoComEconomicComplementsStore';
//DESCARGAR EL DOCUMENTO DE CREACION DEL TRAMITE DE COMPLEMENTO ECONOMICO
String serviceGetPDFEC(int economicComplementId) => '$hostGATEWAY/$reazonMovil/ecoComEconomicComplementsPrint/$economicComplementId';
//SE ENVIA EL ID DEL COMPLEMENTO ECONOMICO - Y SE SABE QUE TIPO DE TRAMITE PUEDE REALIZAR
String serviceEcoComProcedure(int ecoComId) => '$hostGATEWAY/$reazonMovil/ecoComProcedure/$ecoComId';
//SE OBTIENE TODOS LOS APORTES DEL USUARIO
String serviceContributions(int affiliateId) => '$hostGATEWAY/$reazonMovil/contributionsAll/$affiliateId';
//IMPRIMIR SU DOCUMENTO RELACIONADO A SUS APORTES 
String servicePrintContributionPasive(int affiliateId) => '$hostGATEWAY/$reazonMovil/contributionsPassive/$affiliateId';
String servicePrintContributionActive(int affiliateId) => '$hostGATEWAY/$reazonMovil/contributionsActive/$affiliateId';
//INFORMACION SOBRE LOS PRESTAMOS DEL USUARIO
String serviceLoans(int affiliateId) => '$hostGATEWAY/$reazonMovil/loanInformation/$affiliateId';
//IMPRIMIR SOBRE EL PRESTAMO DEL USUARIO
String servicePrintLoans(int loanId) => '$hostGATEWAY/$reazonMovil/loanPrintPlan/$loanId';
//IMPRIMIR EL KARDEX DEL PRESTAMO
String servicePrintKadex(int loanId) => '$hostGATEWAY/$reazonMovil/loanPrintKardex/$loanId';
//"CIUDADANIA DIGITAL -SERVICIO DE AUTENTICACION"
String serviceGetCredentials() => '$hostSTI/app/assignmentcredentials';
String serviceVerificationCode() => '$hostSTI/app/verificationcode';
