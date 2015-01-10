// -*- c++ -*-

// @HEADER
// ***********************************************************************
//
//              PyTrilinos: Python Interface to Trilinos
//                 Copyright (2005) Sandia Corporation
//
// Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
// license for use of this work by or on behalf of the U.S. Government.
//
// This library is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 2.1 of the
// License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
// USA
// Questions? Contact Bill Spotz (wfspotz@sandia.gov)
//
// ***********************************************************************
// @HEADER

// This SWIG interface file includes all of the wrapping content for
// the NOX.Abstract module.  However, it intentionally lacks a %module
// directive because it is supposed to be %include-d from a SWIG
// interface file that does.  There are two such interface files:
// NOX.Abstract.i and NOX.Abstract_RelPath.i.  The first is the actual
// interface file that generates a wrapper file that gets compiled.
// Its %module directive includes the full package name.  The second
// is a special interface file that gets %import-ed from the
// NOX.Epetra.__init__.i file.  It does not include any package
// information.

%{
// Teuchos includes
#include "Teuchos_Comm.hpp"
#include "Teuchos_DefaultSerialComm.hpp"
#ifdef HAVE_MPI
#include "Teuchos_DefaultMpiComm.hpp"
#endif
#include "PyTrilinos_Teuchos_Util.h"

// NOX includes
#include "NOX_Abstract_Group.H"
#include "NOX_Abstract_PrePostOperator.H"
#include "NOX_Abstract_MultiVector.H"
#include "NOX_Abstract_Vector.H"
#include "NOX_Solver_Generic.H"

// Local includes
#define NO_IMPORT_ARRAY
#include "numpy_include.h"
%}

// Configuration and optional includes
%include "PyTrilinos_config.h"
#ifdef HAVE_NOX_EPETRA
%{
#include "NOX_Epetra_Group.H"
#include "NOX_Epetra_Vector.H"
#include "Epetra_NumPyVector.h"
%}
#endif

// Standard exception handling
%include "exception.i"

// Include NOX documentation
%include "NOX_dox.i"

// General ignore directives
%ignore *::operator=;
%ignore *::operator[];

// Trilinos module imports
%import "Teuchos.i"

// General exception handling
%feature("director:except")
{
  if ($error != NULL)
  {
    throw Swig::DirectorMethodException();
  }
}

%exception
{
  try
  {
    $action
  }
  catch(Swig::DirectorException &e)
  {
    SWIG_fail;
  }
  SWIG_CATCH_STDEXCEPT
  catch(...)
  {
    SWIG_exception(SWIG_UnknownError, "Unkown C++ exception");
  }
}

// Support for Teuchos::RCPs
%teuchos_rcp(NOX::Abstract::Group)

#ifdef HAVE_NOX_EPETRA
// Downcast NOX::Abstract::Vector return arguments to Epetra.Vectors,
// if possible
%typemap(out) NOX::Abstract::Vector &
(NOX::Epetra::Vector* nevResult = NULL)
{
  nevResult = dynamic_cast<NOX::Epetra::Vector*>($1);
  if (nevResult == NULL)
  {
    // If we cannot downcast, then return the NOX::Abstract::Vector
    $result = SWIG_NewPointerObj((void*)&$1, $descriptor, SWIG_POINTER_OWN);
  }
  else
  {
    Teuchos::RCP< PyTrilinos::Epetra_NumPyVector > *smartresult = new
      Teuchos::RCP< PyTrilinos::Epetra_NumPyVector >(new PyTrilinos::Epetra_NumPyVector(View,
								nevResult->getEpetraVector(),
								0), bool($owner));
    %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult),
				   $descriptor(Teuchos::RCP< PyTrilinos::Epetra_NumPyVector > *),
				   SWIG_POINTER_OWN));
  }
}

%typemap(out) Teuchos::RCP< const NOX::Abstract::Vector >
(Teuchos::RCP< const NOX::Epetra::Vector > nevResult)
{
  nevResult = Teuchos::rcp_dynamic_cast< const NOX::Epetra::Vector >(*(&$1));
  if (nevResult.is_null())
  {
    // If we cannot downcast, then return the NOX::Abstract::Vector
    Teuchos::RCP< const NOX::Abstract::Vector > *smartresult = $1.is_null() ? 0 :
      new Teuchos::RCP< const NOX::Abstract::Vector >($1);
    %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult),
				   $descriptor(Teuchos::RCP< NOX::Abstract::Vector > *),
				   SWIG_POINTER_OWN));
  }
  else
  {
    Teuchos::RCP< const PyTrilinos::Epetra_NumPyVector > *smartresult = new
      Teuchos::RCP< const PyTrilinos::Epetra_NumPyVector >(new PyTrilinos::Epetra_NumPyVector(View,
								      (*nevResult).getEpetraVector(),
								      0), bool($owner));
    %set_output(SWIG_NewPointerObj(%as_voidptr(smartresult),
				   $descriptor(Teuchos::RCP< PyTrilinos::Epetra_NumPyVector > *),
				   SWIG_POINTER_OWN));
  }
}
#endif

// Declare class to be stored with Teuchos::RCP< >
%teuchos_rcp(NOX::Solver::Generic)

////////////////////////////////
// NOX_Abstract_Group support //
////////////////////////////////
%ignore *::getX;
%ignore *::getF;
%ignore *::getGradient;
%ignore *::getNewton;
%rename(getX       ) *::getXPtr;
%rename(getF       ) *::getFPtr;
%rename(getGradient) *::getGradientPtr;
%rename(getNewton  ) *::getNewtonPtr;
%include "NOX_Abstract_Group.H"

//////////////////////////////////////////
// NOX_Abstract_PrePostOperator support //
//////////////////////////////////////////
%feature("director") NOX::Abstract::PrePostOperator;
%include "NOX_Abstract_PrePostOperator.H"

//////////////////////////////////////
// NOX_Abstract_MultiVector support //
//////////////////////////////////////
%ignore NOX::Abstract::MultiVector::clone(int) const;
%rename(_print) NOX::Abstract::MultiVector::print;
%include "NOX_Abstract_MultiVector.H"

/////////////////////////////////
// NOX_Abstract_Vector support //
/////////////////////////////////
%rename(_print) NOX::Abstract::Vector::print;
%include "NOX_Abstract_Vector.H"

// Turn off the exception handling
%exception;