// $Id$
// $Source$

//@HEADER
// ************************************************************************
//
//            NOX: An Object-Oriented Nonlinear Solver Package
//                 Copyright (2002) Sandia Corporation
//
// Under terms of Contract DE-AC04-94AL85000, there is a non-exclusive
// license for use of this work by or on behalf of the U.S. Government.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// 1. Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// 3. Neither the name of the Corporation nor the names of the
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Questions? Contact Roger Pawlowski (rppawlo@sandia.gov) or
// Eric Phipps (etphipp@sandia.gov), Sandia National Laboratories.
// ************************************************************************
//  CVS Information
//  $Source$
//  $Author$
//  $Date$
//  $Revision$
// ************************************************************************
//@HEADER

#ifndef NOX_SOLVER_SINGLESTEP_H
#define NOX_SOLVER_SINGLESTEP_H

#include "NOX_Solver_Generic.H"  // for NOX::StatusTest::StatusType
#include "NOX_Solver_PrePostOperator.H"  // class data element
#include "NOX_Utils.H"                 // class data element
#include "NOX_Abstract_Group.H"        // argument type

// Forward declarations
namespace NOX {
  class GlobalData;
}

namespace NOX {
namespace Solver {

/*!
  \brief Light wrapper over linear solver, executes exactly one iteration.

  This class exists to support applications which always instantiate a NOX
  Nonlinear solver via the NOX::Solver::Factory, but may be used to
  solve known linear problems.
  In that case, it is convenient to create a NOX::Solver object which requires
  no status tests and simply executes the linear solver.
 */
class SingleStep : public Generic {

public:

  SingleStep(const Teuchos::RCP<NOX::Abstract::Group>& grp,
         const Teuchos::RCP<Teuchos::ParameterList>& params);
  virtual ~SingleStep();
  virtual void reset(const NOX::Abstract::Vector& initial_guess);
  virtual void reset(const NOX::Abstract::Vector& initial_guess,
             const Teuchos::RCP<NOX::StatusTest::Generic>& test);
  virtual NOX::StatusTest::StatusType getStatus();
  virtual NOX::StatusTest::StatusType step();
  virtual NOX::StatusTest::StatusType solve();
  virtual const NOX::Abstract::Group& getSolutionGroup() const;
  virtual Teuchos::RCP< const NOX::Abstract::Group > getSolutionGroupPtr() const;
  virtual const NOX::Abstract::Group& getPreviousSolutionGroup() const;
  virtual Teuchos::RCP< const NOX::Abstract::Group > getPreviousSolutionGroupPtr() const;
  virtual int getNumIterations() const;
  virtual const Teuchos::ParameterList& getList() const;
  virtual Teuchos::RCP< const Teuchos::ParameterList > getListPtr() const;

protected:

  //! Print out initialization information and calcuation the RHS.
  virtual void init();

  //! Prints some status information.
  virtual void printUpdate();

  //! Prints some status information.
  bool check(Abstract::Group::ReturnType ret, const std::string& task);

  //! Prints some status information.
  bool try_step();

protected:

  //! Pointer to the global data object.
  Teuchos::RCP<NOX::GlobalData> globalDataPtr;

  //! Utils
  Teuchos::RCP<NOX::Utils> utilsPtr;

  //! Current solution.
  Teuchos::RCP<NOX::Abstract::Group> solnPtr;

  //! Previous solution pointer.
  Teuchos::RCP<NOX::Abstract::Group> oldSolnPtr;

  //! Input parameters.
  Teuchos::RCP<Teuchos::ParameterList> paramsPtr;

  //! Number of nonlinear iterations.
  int nIter;

  //! %Status of nonlinear solver.
  NOX::StatusTest::StatusType status;

  //! Pointer to a user defined NOX::Abstract::PrePostOperator object.
  NOX::Solver::PrePostOperator prePostOperator;

};
} // namespace Solver
} // namespace NOX

#endif

