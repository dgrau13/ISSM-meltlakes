/*! \file DoubleMatArrayParam.h 
 *  \brief: header file for object holding an array of serial matrices
 */

#ifndef _DOUBLEMATARRAYPARAM_H_
#define _DOUBLEMATARRAYPARAM_H_

/*Headers:*/
/*{{{*/
#ifdef HAVE_CONFIG_H
	#include <config.h>
#else
#error "Cannot compile with HAVE_CONFIG_H symbol! run configure first!"
#endif

#include "./Param.h"
#include "../../shared/shared.h"
/*}}}*/

class DoubleMatArrayParam: public Param{

	private: 
		int          enum_type;
		IssmDouble **array;        //array of matrices
		int          M;            //size of array
		int         *mdim_array;   //m-dimensions of matrices in the array
		int         *ndim_array;   //n-dimensions -f matrices in the array

	public:
		/*DoubleMatArrayParam constructors, destructors: {{{*/
		DoubleMatArrayParam();
		DoubleMatArrayParam(int enum_type,IssmDouble** array, int M, int* mdim_array, int* ndim_array);
		~DoubleMatArrayParam();
		/*}}}*/
		/*Object virtual functions definitions:{{{ */
		Param* copy();
		void  DeepEcho();
		void  Echo();
		int   Id(); 
		void Marshall(MarshallHandle* marshallhandle);
		int   ObjectEnum();
		/*}}}*/
		/*Param virtual function definitions: {{{*/
		void  GetParameterValue(bool* pbool){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a bool");}
		void  GetParameterValue(int* pinteger){_error_("Param "<< EnumToStringx(enum_type) << "cannot return an integer");}
		void  GetParameterValue(int** pintarray,int* pM){_error_("Param "<< EnumToStringx(enum_type) << "cannot return an array of integers");}
		void  GetParameterValue(int** pintarray,int* pM,int* pN){_error_("Param "<< EnumToStringx(enum_type) << "cannot return an array of integers");}
		void  GetParameterValue(IssmDouble* pIssmDouble){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a IssmDouble");}
		void  GetParameterValue(IssmDouble* pdouble,IssmDouble time){_error_("Param "<< EnumToStringx(enum_type) << " cannot return a IssmDouble for a given time");}
		void  GetParameterValue(IssmDouble* pdouble,IssmDouble time, int timestepping, IssmDouble dt){_error_("Param "<< EnumToStringx(enum_type) << " cannot return a IssmDouble for a given time");}
		void  GetParameterValue(char** pstring){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a string");}
		void  GetParameterValue(char*** pstringarray,int* pM){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a string array");}
		void  GetParameterValue(IssmDouble** pIssmDoublearray,int* pM){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a IssmDouble array");}
		void  GetParameterValue(IssmDouble** pIssmDoublearray,int* pM, int* pN){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a IssmDouble array");}
		void  GetParameterValue(IssmDouble** pIssmDoublearray,int* pM, const char* data){_error_("Param "<< EnumToStringx(enum_type) << " cannot return a IssmDouble array");}
		void  GetParameterValue(IssmDouble*** parray, int* pM,int** pmdims, int** pndims);
		void  GetParameterValue(Vector<IssmDouble>** pvec){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a Vec");}
		void  GetParameterValue(Matrix<IssmDouble>** pmat){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a Mat");}
		void  GetParameterValue(FILE** pfid){_error_("Param "<< EnumToStringx(enum_type) << "cannot return a FILE");}
		void  GetParameterValue(DataSet** pdataset){_error_("Param "<< EnumToStringx(enum_type) << " cannot return a DataSet");}
		int   InstanceEnum(){return enum_type;}

		void  SetEnum(int enum_in){this->enum_type = enum_in;};
		void  SetValue(bool boolean){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a boolean");}
		void  SetValue(int integer){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold an integer");}
		void  SetValue(IssmDouble scalar){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a scalar");}
		void  SetValue(char* string){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a string");}
		void  SetValue(char** stringarray,int M){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a string array");}
		void  SetValue(IssmDouble* IssmDoublearray){_error_("Param "<< EnumToStringx(enum_type) << " cannot hold a IssmDouble array");}
		void  SetValue(IssmDouble* IssmDoublearray,int M){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a IssmDouble vec array");}
		void  SetValue(IssmDouble* IssmDoublearray,int M,int N){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a IssmDouble mat array");}
		void  SetValue(int* intarray,int M){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a int vec array");}
		void  SetValue(int* intarray,int M,int N){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a int mat array");}
		void  SetValue(Vector<IssmDouble>* vec){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a Vec");}
		void  SetValue(Matrix<IssmDouble>* mat){_error_("Param "<< EnumToStringx(enum_type) << "cannot hold a Mat");}
		void  SetValue(FILE* fid){_error_("Bool param of enum " << enum_type << " (" << EnumToStringx(enum_type) << ") cannot hold a FILE");}
		void  SetValue(IssmDouble** array, int M, int* mdim_array, int* ndim_array);
		void  SetGradient(IssmDouble* poutput, int M, int N){_error_("Param "<< EnumToStringx(enum_type) << " cannot hold an IssmDouble");};
		/*}}}*/
};
#endif  /* _DOUBLEMATARRAYPARAM_H */
