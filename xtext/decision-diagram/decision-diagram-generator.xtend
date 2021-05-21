/*
 * generated by Xtext 2.22.0
 */
package dk.sdu.mmmi.mdsd.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.emf.ecore.xmi.impl.XMLResourceImpl
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.DecisionDiagram
import javax.swing.JFrame
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.Initial
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.Goal
import javax.swing.JOptionPane
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.NamedTarget
import java.util.HashMap
import java.util.ArrayList
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.Option
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.Question
import dk.sdu.mmmi.mdsd.decisionDiagramLanguage.Target
import org.eclipse.emf.common.util.EList

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class DecisionDiagramLanguageGenerator extends AbstractGenerator {

	val identityMap = new HashMap<Target,Integer>
	var id = 0
	var initialTarget = -1

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val model = resource.allContents.filter(DecisionDiagram).next
		model.display
		//model.execute
		model.targets.forEach[identityMap.put(it,id++)]
		model.targets.forEach[if(it instanceof Initial) initialTarget = identityMap.get(it)]
		fsa.generateFile("dd/DecisionDiagram.java",model.generateDD)
	}
		
	def CharSequence generateDD(DecisionDiagram diagram) '''
	package dd;
	import java.util.ArrayList;
	import java.util.HashMap;
	import java.util.List;
	import java.util.Map;
	import javax.swing.JFrame;
	import javax.swing.JOptionPane;
	public class DecisionDiagram {
		public static void main(String argv[]) {
			JFrame frame = new JFrame("«diagram.title»");
			int q = «initialTarget»; // Current question
			while(true) {
			  switch(q) {
			  «FOR t:identityMap.keySet»
			  case «identityMap.get(t)»: {
			    «t.generateTarget»
			  }
			  «ENDFOR»
			  }
			}
		}
	}
	'''
		
	def dispatch generateTarget(Initial i) { generateDisplayOptions(i.title,i.options) }
	def dispatch generateTarget(Question q) { generateDisplayOptions(q.title,q.options) }
	def dispatch generateTarget(Goal g) '''
	JOptionPane.showMessageDialog(frame,"«g.title»");
	return;
	'''

	def generateDisplayOptions(String title, EList<Option> options) '''
	String[] prim = new String[] {
		«FOR o:options SEPARATOR ","»"«o.text»"«ENDFOR»
	};
	String answer = (String) JOptionPane.showInputDialog(frame, 
					         "«title»",
					         "«title»",
					         JOptionPane.QUESTION_MESSAGE, 
					         null, 
					         prim, 
					         prim[0]);
	«FOR o:options»
	if(answer.equals("«o.text»")) q = «identityMap.get(o.to)»;
	«ENDFOR»
	break;
	'''
		
		
	// Other stuff	
	
	def dispatch getOptions(Question target) { target.options }
	def dispatch getOptions(Initial target) { target.options }
		
	def execute(DecisionDiagram model) {
		val frame = new JFrame(model.title);
		var Target currentTarget = model.targets.filter(Initial).iterator.next
		while(true) {
			val text = currentTarget.title
			if(currentTarget instanceof Goal) {
				JOptionPane.showMessageDialog(frame,text)
				return
			} else {
				val opts = new ArrayList<String>
				val targets = new HashMap<String,NamedTarget>
				for(Option t: currentTarget.options) {
					opts.add(t.getText())
					targets.put(t.getText(),t.to);
				}
				val String[] prim = newArrayOfSize(opts.size())
				for(var int i=0; i<opts.size(); i++) prim.set(i,opts.get(i))
				val answer = JOptionPane.showInputDialog(frame, 
				        text,
				        text,
				        JOptionPane.QUESTION_MESSAGE, 
				        null, 
				        prim, 
				        prim.get(0)) as String
				currentTarget = targets.get(answer);
			}
		}
		
	}
	
	def display(EObject model) {
  		val res = new XMLResourceImpl
  		res.contents.add(EcoreUtil::copy(model))
  		System::out.println("Dump of model:")
  		res.save(System.out, null);
	}
	
}